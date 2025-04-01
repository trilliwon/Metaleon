//
//  VignetteColorBurnFilter.metal
//  Metaleon
//
//  Created by trilliwon on 27/05/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

#include <metal_stdlib>
#include "CommonOperationTypes.h"

using namespace metal;

float blend_5(float base, float blend) {
    return (blend <= 0.0 ? base : (1.0 - (1.0 - base) / blend));
}

fragment float4 vignetteColorBurnFilter(VertexIO         inputFragment [[ stage_in ]],
                                       texture2d<float>  inputTexture  [[ texture(0) ]],
                                       texture2d<float>  lookupTexture  [[ texture(1) ]],
                                       constant AlphaUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    float2 pos = inputFragment.textureCoord;

    float4 texColor = inputTexture.sample(textureSampler, pos).rgba;
    float2 vignetteCoord = float2(1.0) - 2.0 * abs(float2(0.5) - pos);
    float4 vignetteColor = lookupTexture.sample(textureSampler, vignetteCoord).rgba;
    float3 blendedColor = float3(blend_5(texColor.r, vignetteColor.r), blend_5(texColor.g, vignetteColor.g), blend_5(texColor.b, vignetteColor.b));

    float4 fragColor = float4(mix(texColor.rgb, blendedColor, vignetteColor.a * uniform.alpha), 1.0);

    return fragColor;
}
