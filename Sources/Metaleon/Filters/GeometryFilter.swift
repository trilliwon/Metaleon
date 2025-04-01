//
//  GeometryFilter.swift
//  Metaleon
//
//  Created by trilliwon on 12/06/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import MetalKit

final public class GeometryFilter {

    var description: String {
        return String(describing: self)
    }

    private let containerBound: CGRect
    private var renderPipelineState: MTLRenderPipelineState?
    private let renderPassDescriptor = MTLRenderPassDescriptor()
    private var heap: MTLHeap?

    private var textureWidth: Int = 0
    private var textureHeight: Int = 0

    var textureMirroring: Bool = true
    private var internalMirroring: Bool = false

    private var vertexCoordBuffer: MTLBuffer?
    private lazy var textCoordBuffer: MTLBuffer? = MetalDevice.shared.makeDefaultTextureCoodBuffer()

    public init(containerBound: CGRect) {
        self.containerBound = containerBound
        (self.renderPipelineState, _) = MetalDevice.shared.makeRenderPipelineState(vertextFuncName: ShaderFuncName.Vertex.passThrough.rawValue,
                                                                                   fragmentFuncName: ShaderFuncName.Fragment.passThrough.rawValue)
    }

    fileprivate func setupTransform(width: Int, height: Int, mirroring: Bool) {
        textureWidth = width
        textureHeight = height
        internalMirroring = mirroring
        vertexCoordBuffer = MetalDevice.shared.makeAspectFillVertextCoodBuffers(bounds: containerBound,
                                                                                textureWidth: width,
                                                                                textureHeight: height,
                                                                                textureMirroring: internalMirroring)
    }

    public func encode(to commandBuffer: MTLCommandBuffer, sourceTexture: MTLTexture) -> MTLTexture {

        if textureWidth != sourceTexture.width || textureHeight != sourceTexture.height || textureMirroring != internalMirroring {
            setupTransform(width: sourceTexture.width, height: sourceTexture.height, mirroring: textureMirroring)
        }

        var destination: MTLTexture?

        if let heap = heap {
            destination = heap.makeTexture(descriptor: sourceTexture.texture2DDescriptor)
            destination?.makeAliasable()
        } else {
            if let heap = MetalDevice.shared.makeHeap(textureDescriptor: sourceTexture.texture2DDescriptor) {
                self.heap = heap
                destination = self.heap?.makeTexture(descriptor: sourceTexture.texture2DDescriptor)
                destination?.makeAliasable()
            } else {
                destination = MetalDevice.shared.makeTexture(descriptor: sourceTexture.texture2DDescriptor)
            }
        }

        guard let destinationTexture = destination else {
            return sourceTexture
        }

        renderPassDescriptor.colorAttachments[0].texture = destinationTexture
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].loadAction = .clear

        guard let renderPipelineState = renderPipelineState else {
            return sourceTexture
        }

        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return sourceTexture
        }

        defer {
            commandEncoder.waitForFence(MetalDevice.shared.fence, before: MTLRenderStages.fragment)
            commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4) // square
            commandEncoder.updateFence(MetalDevice.shared.fence, after: MTLRenderStages.fragment)
            commandEncoder.endEncoding()
        }

        commandEncoder.label = description
        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(vertexCoordBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(textCoordBuffer, offset: 0, index: 1)
        commandEncoder.setFragmentTexture(sourceTexture, index: 0)

        return destinationTexture
    }
}
