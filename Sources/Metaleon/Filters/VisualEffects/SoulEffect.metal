//
//  SoulEffect.metal
//  Metaleon
//
//  Created by trilliwon on 20/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

constant float duration = 400;
constant float delay = 100;
constant float maxMag = 4;
constant float startIntensity = 0.5;
constant float2 center = float2(.5, .5);

fragment float4 soulEffect(VertexIO inputFragment [[ stage_in ]],
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

    float4 orig = inputTexture.sample(textureSampler, pos).rgba;
    float4 soul = inputTexture.sample(textureSampler, uv).rgba;
    return float4(mix(soul, orig, (t * startIntensity) + (1. - startIntensity)));
}
