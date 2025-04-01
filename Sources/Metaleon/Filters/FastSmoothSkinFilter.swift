//
//  FastSmoothSkinFilter.swift
//  Metaleon
//
//  Created by trilliwon on 27/05/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import MetalKit

final class FastSmoothSkinFilter: BasicRenderFilter, ParamLessInitializable {

    private let bilateralFilter = BilateralFilter()

    init() {
        super.init(fragmentFuncName: .fastSmoothSkin)
        updateParameters(with: ["smoothDegree": 0.5])
    }

    override func encode(to commandBuffer: MTLCommandBuffer, inputTextures: [TextureIndex: MTLTexture]) -> MTLTexture {
        let bilateralTexture = bilateralFilter.encode(to: commandBuffer, inputTextures: inputTextures)

        var inputTextures = inputTextures
        inputTextures[1] = bilateralTexture
        return super.encode(to: commandBuffer, inputTextures: inputTextures)
    }
}
