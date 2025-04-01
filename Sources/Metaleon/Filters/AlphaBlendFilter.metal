//
//  AlphaBlendFilter.metal
//  Metaleon
//
//  Created by trilliwon on 22/05/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

#include <metal_stdlib>
#include "CommonOperationTypes.h"

using namespace metal;

fragment float4 alphaBlendFilter(TwoInputVertexIO fragmentInput [[stage_in]],
                                    texture2d<float> inputTexture [[texture(0)]],
                                    texture2d<float> inputTextureBlend [[texture(1)]],
                                    constant AlphaUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    float2 pos = fragmentInput.textureCoordinate;
    float4 origin = inputTexture.sample(textureSampler, pos).rgba;
    float4 blend = inputTextureBlend.sample(textureSampler, pos).rgba;
    float4 color = float4(mix(origin.xyz, blend.xyz, blend.w * uniform.alpha), origin.w);

    return color;
}
