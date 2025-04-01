//
//  VHSCameraEffectFilter.swift
//  Metaleon
//
//  Created by trilliwon on 18/07/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import MetalKit

final public class VHSCameraEffectFilter: BasicRenderFilter {

    private var timer: Float = 0

    public init() {
        super.init(fragmentFuncName: .vhsCamera)
        updateParameters(with: ["currentTime" : 0.0])
    }

    public override func encode(to commandBuffer: MTLCommandBuffer, inputTextures: [TextureIndex: MTLTexture]) -> MTLTexture {
        updateParameters(with: ["currentTime" : timer])
        timer += (1.0 / 60.0)
        return super.encode(to: commandBuffer, inputTextures: inputTextures)
    }
}

// https://www.shadertoy.com/view/WdSXRt
