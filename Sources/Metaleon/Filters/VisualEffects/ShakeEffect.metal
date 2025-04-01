//
//  ShakeEffect.metal
//  Metaleon
//
//  Created by trilliwon on 20/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

constant float duration = 200;
constant float delay = 300;
constant float maxMag = 1.2;
constant float2 center = float2(.5, .5);
constant float2 offset_r = float2(0., 0.1);
constant float2 offset_g = float2(0., -0.1);
constant float2 offset_b = float2(0., 0.);

fragment float4 shakeEffect(VertexIO inputFragment [[ stage_in ]],
                           texture2d<float> inputTexture [[ texture(0) ]],
                           constant CurrentTimeUniform& uniform [[ buffer(1) ]])
{
    float2 pos = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    float currentTime = float(int(uniform.currentTime * 1000) % 500);
    float period = duration + delay;
    float mag = 1. - 1. / maxMag;
    float t = smoothstep(0., duration, fmod(currentTime, period));
    float mv = t * mag;
    mv = mv * (1. - step(mag, mv));
    float2 uv = (pos - center) * (1. - mv) + center;

    float r = inputTexture.sample(textureSampler, uv + offset_r * mv).r;
    float g = inputTexture.sample(textureSampler, uv + offset_g * mv).g;
    float b = inputTexture.sample(textureSampler, uv + offset_b * mv).b;

    return float4(r, g, b, 1.);
}
