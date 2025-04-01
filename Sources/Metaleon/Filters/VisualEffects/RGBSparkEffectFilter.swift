//
//  RGBSparkEffectFilter.swift
//  Metaleon
//
//  Created by trilliwon on 20/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import MetalKit

final public class RGBSparkEffectFilter: BasicRenderFilter {

    private let FRAME_COUNT = 9//3 * 2 + 3
    private let FRAME_IDX_R = 0
    private let FRAME_IDX_G = 4//3 + 1
    private let FRAME_IDX_B = 8//3 * 2 + 2
    private var textureCache: [MTLTexture] = []

    public init() {
        super.init(fragmentFuncName: .rgbSpark)
    }

    public override func encode(to commandBuffer: MTLCommandBuffer, inputTextures: [TextureIndex: MTLTexture]) -> MTLTexture {
        guard let sourceTexture = inputTextures[0] else {
            preconditionFailure("Source Texture not found")
        }

        /**
         input texture 들이 서로 달라야 하기 때문에 blitCommandEncoder 를 사용해 복사를 진행해야 함.
         아닐 경우 같은 텍스쳐를 여러 인덱스에 캐시하기 때문에 결과가 아주 조금 변화가 있거나 거의 없음.
         */
        let copiedTexture = MetalDevice.shared.copy(commandBuffer: commandBuffer, sourceTexture: sourceTexture)

        textureCache.insert(copiedTexture, at: 0)
        if textureCache.count < FRAME_COUNT {
            return sourceTexture
        } else if textureCache.count > FRAME_COUNT {
            textureCache.removeLast()
        }

        let inputTextures: [TextureIndex: MTLTexture] = [0: copiedTexture,
                                                         1: textureCache[FRAME_IDX_G],
                                                         2: textureCache[FRAME_IDX_G]]

        return super.encode(to: commandBuffer, inputTextures: inputTextures)
    }
}
