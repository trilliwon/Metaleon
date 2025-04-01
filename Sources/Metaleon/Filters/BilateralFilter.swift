//
//  BilateralFilter.swift
//  Metaleon
//
//  Created by trilliwon on 24/05/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import MetalKit

final class BilateralFilter: FilterInitializable {

    var description: String {
        return String(describing: self)
    }

    private let texelOffsetMultiplier: Float = 4
    private var normalizationFactor: Float = 4

    private lazy var texelOffsetmultiplierBufferX: MTLBuffer? = MetalDevice.shared.makeBuffer(length: 2 * MemoryLayout<Float>.size)
    private lazy var texelOffsetmultiplierBufferY: MTLBuffer? = MetalDevice.shared.makeBuffer(length: 2 * MemoryLayout<Float>.size)

    private var internalFilterX = BasicRenderFilter(vertexFuncName: .linearNearBy, fragmentFuncName: .bilateralFragment)
    private var internalFilterY = BasicRenderFilter(vertexFuncName: .linearNearBy, fragmentFuncName: .bilateralFragment)

    init() {
        internalFilterX.updateParameters(with: ["normalizationFactor": normalizationFactor])
        internalFilterX.addVertexBuffer(buffer: texelOffsetmultiplierBufferX)

        internalFilterY.updateParameters(with: ["normalizationFactor": normalizationFactor])
        internalFilterY.addVertexBuffer(buffer: texelOffsetmultiplierBufferY)

        updateTexelOffsetBufferX(offset: [0.0, 0.0])
        updateTexelOffsetBufferY(offset: [0.0, 0.0])
    }

    func encode(to commandBuffer: MTLCommandBuffer, inputTextures: [TextureIndex: MTLTexture]) -> MTLTexture {
        guard let sourceTexture = inputTextures[0] else {
            preconditionFailure("Source Texture Not Found")
        }
        let offsetX = texelOffsetMultiplier / Float(sourceTexture.width)
        updateTexelOffsetBufferX(offset: [offsetX, 0.0])
        let hBlurTexture = internalFilterX.encode(to: commandBuffer, inputTextures: inputTextures)

        let offsetY = texelOffsetMultiplier / Float(sourceTexture.height)
        updateTexelOffsetBufferY(offset: [0.0, offsetY])

        var inputTextures = inputTextures
        inputTextures[0] = hBlurTexture
        let result = internalFilterY.encode(to: commandBuffer, inputTextures: inputTextures)
        return result
    }

    func updateTexelOffsetBufferX(offset: [Float]) {
        var offset = offset
        let bufferPointer = texelOffsetmultiplierBufferX?.contents()
        memcpy(bufferPointer, &offset, 2 * MemoryLayout<Float>.size)
    }

    func updateTexelOffsetBufferY(offset: [Float]) {
        var offset = offset
        let bufferPointer = texelOffsetmultiplierBufferY?.contents()
        memcpy(bufferPointer, &offset, 2 * MemoryLayout<Float>.size)
    }

    func updateParameters(with parameters: [String : Float]) {
        if let value = parameters["normalizationFactor"] {
            internalFilterY.updateParameters(with: ["normalizationFactor": value])
        }
    }
}
