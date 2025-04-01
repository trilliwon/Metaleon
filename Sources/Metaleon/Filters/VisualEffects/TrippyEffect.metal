//
//  TrippyEffect.metal
//  Metaleon
//
//  Created by trilliwon on 20/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include <metal_common>
#include "../CommonOperationTypes.h"

using namespace metal;

constant float u_period = 0.1;
constant float u_delay = 0.2;

float4 rgb2gray(float4 color) {
    return float4(float3(clamp((color.b * 0.45703125 + color.g * 2.34765625 + color.r * 1.1953125) / 4.0, 0.0, 1.0)), 1.0);
};


fragment float4 trippyEffect(VertexIO inputFragment [[ stage_in ]],
                            texture2d<float> inputTexture [[ texture(0) ]],
                            constant CurrentTimeUniform& uniform [[ buffer(1) ]])
{
    float2 pos = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    float u_currentTime = uniform.currentTime;

    float scene = fmod(u_currentTime, u_period + u_delay);
    float scene2 = fmod(u_currentTime, (u_period + u_delay) * 2.0);
    float edge = step(u_period + u_delay, scene2); //0.0 or 1.0

    float normalized = smoothstep(0.0, u_period, scene);
    float curve = sin(normalized * 3.141592);
    float curve2 = abs(edge - normalized);

    float dist = curve * 0.2;
    float2 leftCoord = float2(max(pos.x - dist, 0.), pos.y);
    float2 rightCoord = float2(min(pos.x, 1.), pos.y);
    float4 left = inputTexture.sample(textureSampler, leftCoord).rgba;
    float4 right = inputTexture.sample(textureSampler, rightCoord).rgba;

    float4 mixed = mix(left, right, 0.5);
    float4 gray = rgb2gray(mixed);

    return float4(mix(gray, mixed, curve2));
}
