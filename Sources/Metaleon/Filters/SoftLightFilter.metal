//
//  SoftLightFilter.metal
//  Metaleon
//
//  Created by trilliwon on 22/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "CommonOperationTypes.h"

using namespace metal;

float blend(float base, float blend) {
    if (blend < 0.5) {
        return 2.0 * base * blend + base * base * (1.0 - 2.0 * blend);
    } else {
        return sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend);
    }
}

fragment float4 softLightFragment(VertexIO fragmentInput [[ stage_in ]],
                                 texture2d<float> inputTextureOrigin [[ texture(0) ]],
                                 texture2d<float> inputTextureBlend  [[ texture(1) ]],
                                 constant AlphaUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler samplr;
    float4 originColor = inputTextureOrigin.sample(samplr, fragmentInput.textureCoord);

    constexpr sampler samplr1;
    float4 blendColor = inputTextureBlend.sample(samplr1, fragmentInput.textureCoord);

    float3 blendedColor = float3(blend(originColor.r, blendColor.r), blend(originColor.g, blendColor.g), blend(originColor.b, blendColor.b));

    float4 color = float4(mix(originColor.rgb, blendedColor.rgb.rgb, float(uniform.alpha)), 1.0);

    return color;
}
