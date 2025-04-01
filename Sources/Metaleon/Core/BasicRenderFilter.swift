//
//  BasicRenderFilter.swift
//  Metaleon
//
//  Created by trilliwon on 31/05/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import Metal

public class BasicRenderFilter: Filter {

    public var description: String {
        return String(describing: self)
    }

    private var renderPipelineState: MTLRenderPipelineState?
    private let renderPassDescriptor = MTLRenderPassDescriptor()

    private var vertexBuffers: [MTLBuffer?] = []

    private let fragmentArguments: [MTLArgument]
    private var fragmentArgumentsInfo: [(name: String, index: Int, size: Int)] = []
    private var fragmentBuffers: [String: MTLBuffer] = [:]

    public let staticInputTextures: [TextureIndex: MTLTexture]

    public init(vertexFuncName: ShaderFuncName.Vertex = .passThrough,
                fragmentFuncName: ShaderFuncName.Fragment,
                inputTextures: [TextureIndex: MTLTexture] = [:]) {

        self.staticInputTextures = inputTextures

        (self.renderPipelineState, self.fragmentArguments) = MetalDevice.shared.makeRenderPipelineState(vertextFuncName: vertexFuncName.rawValue,
                                                                                                        fragmentFuncName: fragmentFuncName.rawValue)

        fragmentArgumentsInfo = generateFragmentArgsInfo(arguments: fragmentArguments)
        fragmentBuffers = fragmentArgumentsInfo.reduce(into: [:], { $0[$1.name] = MetalDevice.shared.makeBuffer(length: $1.size) })

        // set default vertex buffers
        vertexBuffers = [MetalDevice.shared.makeDefaultVertexCoodBuffers(), MetalDevice.shared.makeDefaultTextureCoodBuffer()]
    }

    private func generateFragmentArgsInfo(arguments: [MTLArgument]) -> [(name: String, index: Int, size: Int)] {
        return arguments
            .filter { $0.type == .buffer && $0.bufferDataType == .struct } // take only buffers are struct type
            .compactMap { $0.bufferStructType?.members }
            .reduce([], +)
            .map { ($0.name, $0.argumentIndex + 1, MemoryLayout<Float>.size) } // fragment buffer is only float type
    }

    public func addVertexBuffer(buffer: MTLBuffer?) {
        if let buffer = buffer {
            self.vertexBuffers.append(buffer)
        }
    }

    public func updateParameters(with parameters: [String: Float]) {
        for (key, buffer) in fragmentBuffers {
            if let parameterValue = parameters[key] {
                buffer.update(value: parameterValue)
            }
        }
    }

    public func encode(to commandBuffer: MTLCommandBuffer, destinationTexture: MTLTexture, sourceTexture: MTLTexture) {
        encode(to: commandBuffer, destinationTexture: destinationTexture, inputTextures: [0: sourceTexture])
    }

    public func encode(to commandBuffer: MTLCommandBuffer, inputTextures: [TextureIndex: MTLTexture]) -> MTLTexture {
        guard let sourceTexture = inputTextures[0] else {
            preconditionFailure("Source Texture not found")
        }

        guard let destinationTexture = MetalDevice.shared.makeTextureFromCreationHeap(descriptor: sourceTexture.texture2DDescriptor) else {
            return sourceTexture
        }

        encode(to: commandBuffer, destinationTexture: destinationTexture, inputTextures: inputTextures)
        return destinationTexture
    }

    public func encode(to commandBuffer: MTLCommandBuffer, destinationTexture: MTLTexture, inputTextures: [TextureIndex: MTLTexture]) {

        renderPassDescriptor.colorAttachments[0].texture = destinationTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear

        guard let renderPipelineState = renderPipelineState else { return }
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }

        defer {
            // Wait for compute to finish before executing the fragment stage
            commandEncoder.waitForFence(MetalDevice.shared.fence, before: MTLRenderStages.fragment)
            commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            commandEncoder.updateFence(MetalDevice.shared.fence, after: MTLRenderStages.fragment)
            commandEncoder.endEncoding()
        }

        commandEncoder.label = description
        commandEncoder.setRenderPipelineState(renderPipelineState)

        // Set vertex buffers
        for (index, buffer) in vertexBuffers.enumerated() {
            commandEncoder.setVertexBuffer(buffer, offset: 0, index: index)
        }

        // Set fragment textures
        for (index, texture) in staticInputTextures {
            commandEncoder.setFragmentTexture(texture, index: index)
        }

        for (index, texture) in inputTextures {
            commandEncoder.setFragmentTexture(texture, index: index)
        }

        // Set fragment buffers
        for argInfo in fragmentArgumentsInfo {
            commandEncoder.setFragmentBuffer(fragmentBuffers[argInfo.name], offset: 0, index: argInfo.index)
        }
    }
}
