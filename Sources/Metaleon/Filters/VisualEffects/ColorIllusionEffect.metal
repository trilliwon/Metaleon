//
//  ColorIllusionEffect.metal
//  Metaleon
//
//  Created by trilliwon on 20/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

constant float PI = 3.1415;
constant float PI2 = 6.2831;

constant float T_SLOW = 0.5;
constant float T_FAST = 0.08;
constant float C_SLOW = 5.0;

constant float T = 0.5 * 5.0 + 0.08 * 6.0;
constant float edge = PI2 * (T_SLOW * C_SLOW / T);

fragment float4 colorIllusionEffect(VertexIO       inputFragment [[stage_in]],
                                   texture2d<float> inputTexture [[texture(0)]],
                                   constant CurrentTimeUniform& uniform [[ buffer(1) ]] )
{

    float2 position = inputFragment.textureCoord;

    // describes how to sample the texture
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    float u_time = float(int(uniform.currentTime * 1000) % int(2980)) / float(1000);
    float t = mix(T_SLOW, T_FAST, step(edge, fmod((PI2 / T) * u_time, PI2)));
    float ty = (sin((PI2 / t) * u_time - PI / 2.) + 1.) / 2.;

    float3 i1 = inputTexture.sample(textureSampler, position).rgb * float3(.7, .3, .3);
    float3 i2 = inputTexture.sample(textureSampler, float2(1. - position.x, position.y)).rgb * float3(.3, .7, .7);

    return float4(mix(i1, i2, ty), 1.0);
}
