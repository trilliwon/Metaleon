//
//  TrailEffectFilter.swift
//  Metaleon
//
//  Created by trilliwon on 20/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import MetalKit

final public class TrailEffectFilter: BasicRenderFilter {

    private var lastTexture: MTLTexture?

    public init() {
        super.init(fragmentFuncName: .trail)
        updateParameters(with: ["isFirstFrame" : 0.0])
    }

    public override func encode(to commandBuffer: MTLCommandBuffer, inputTextures: [TextureIndex: MTLTexture]) -> MTLTexture {
        guard let sourceTexture = inputTextures[0] else {
            preconditionFailure("Source Texture Not Found")
        }
        var inputTextures = inputTextures
        inputTextures[1] = lastTexture ?? sourceTexture
        updateParameters(with: ["isFirstFrame" : lastTexture == nil ? 0.0 : 1.0])
        lastTexture = super.encode(to: commandBuffer, inputTextures: inputTextures)
        return lastTexture ?? sourceTexture
    }
}
