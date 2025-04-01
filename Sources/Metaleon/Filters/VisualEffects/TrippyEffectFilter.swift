//
//  TrippyEffectFilter.swift
//  Metaleon
//
//  Created by trilliwon on 20/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import MetalKit

final public class TrippyEffectFilter: BasicRenderFilter {

    private var timer: Float = 0

    public init() {
        super.init(fragmentFuncName: .trippy)
        updateParameters(with: ["currentTime" : 0.0])
    }

    public override func encode(to commandBuffer: MTLCommandBuffer, inputTextures: [TextureIndex: MTLTexture]) -> MTLTexture {
        updateParameters(with: ["currentTime" : timer])
        timer += (1.0 / 60.0)
        return super.encode(to: commandBuffer, inputTextures: inputTextures)
    }
}
