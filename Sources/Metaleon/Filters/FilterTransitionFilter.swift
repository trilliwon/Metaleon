//
//  FilterTransitionFilter.swift
//  Metaleon
//
//  Created by trilliwon on 21/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import MetalKit

final class FilterTransitionFilter: BasicRenderFilter {

    private var nextTexture: MTLTexture?

    private var edge: Float = 0.0 {
        didSet {
            updateParameters(with: ["edge" : edge])
        }
    }

    init() {
        super.init(fragmentFuncName: .transition)
        updateParameters(with: ["edge" : 0.0])
    }

    override func encode(to commandBuffer: MTLCommandBuffer, inputTextures: [TextureIndex: MTLTexture]) -> MTLTexture {
        guard let sourceTexture = inputTextures[0] else {
            preconditionFailure("Source Texture Not found")
        }
        var inputTextures = inputTextures

        if let nextTexture = nextTexture {
            inputTextures[1] = nextTexture
            return super.encode(to: commandBuffer, inputTextures: inputTextures)
        } else {
            return sourceTexture
        }
    }

    func updateEdge(edge: Float) {
        self.edge = edge
    }

    func provideNextTexture(texture: MTLTexture?) {
        self.nextTexture = texture
    }
}
