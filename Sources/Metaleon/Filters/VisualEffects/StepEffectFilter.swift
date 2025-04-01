//
//  StepEffectFilter.swift
//  Metaleon
//
//  Created by trilliwon on 20/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import MetalKit

final public class StepEffectFilter: BasicRenderFilter {

    public enum Direction {
        case vertical, horizontal

        var fragmentFuncName: ShaderFuncName.Fragment {
            switch self {
            case .vertical:   return .stepVertical
            case .horizontal: return .stepHorizontal
            }
        }
    }

    private let frameDelayCount = 12
    private var currentFrame = 0
    private var texture0: MTLTexture?
    private var texture1: MTLTexture?
    private var texture2: MTLTexture?

    public init(direction: Direction) {
        super.init(fragmentFuncName: direction.fragmentFuncName)
    }

    public override func encode(to commandBuffer: MTLCommandBuffer, inputTextures: [TextureIndex: MTLTexture]) -> MTLTexture {
        guard var sourceTexture = inputTextures[0] else {
            preconditionFailure("Source Texture Not Found")
        }

        sourceTexture = MetalDevice.shared.copy(commandBuffer: commandBuffer, sourceTexture: sourceTexture)

        var step: Float = 0 // Int is better choice
        if texture0 == nil && texture1 == nil && texture2 == nil {
            texture0 = sourceTexture
            texture1 = sourceTexture
            texture2 = sourceTexture
        } else {
            let frameIdx = currentFrame % (frameDelayCount * 3)
            switch frameIdx {
            case 0...(frameDelayCount - 1):
                texture0 = sourceTexture
            case frameDelayCount...(frameDelayCount * 2 - 1):
                texture1 = sourceTexture
                step = 1;
            case (frameDelayCount * 2)...(frameDelayCount * 3 - 1):
                texture2 = sourceTexture
                step = 2;
            default:
                break
            }
        }

        currentFrame += 1

        if currentFrame >= Int.max {
            currentFrame = 0
        }

        updateParameters(with: ["activeStep" : step])

        let inputTextures: [TextureIndex: MTLTexture] = [
            0: sourceTexture,
            1: texture0 ?? sourceTexture,
            2: texture1 ?? sourceTexture,
            3: texture2 ?? sourceTexture
        ]
        return super.encode(to: commandBuffer, inputTextures: inputTextures)
    }
}
