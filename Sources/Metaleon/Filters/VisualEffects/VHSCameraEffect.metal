//
//  VHSCameraEffect.metal
//  Metaleon
//
//  Created by trilliwon on 18/07/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

fragment float4 vhsCameraEffect(VertexIO       inputFragment [[stage_in]],
                                texture2d<float> inputTexture [[texture(0)]],
                                constant CurrentTimeUniform& uniform [[ buffer(1) ]] )
{
    float2 uv = inputFragment.textureCoord;
    constexpr sampler textureSampler;

    float iTime = uniform.currentTime;

    float2 pos = float2(0.5 + 0.5 * sin(iTime), uv.y);
    float3 col = float3(inputTexture.sample(textureSampler, uv));
    float3 col2 = float3(inputTexture.sample(textureSampler, pos)) * 0.2;
    col += col2;

    return float4(col, 1.0);
}
