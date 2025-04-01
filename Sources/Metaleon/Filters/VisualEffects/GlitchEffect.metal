//
//  GlitchEffect.metal
//  Metaleon
//
//  Created by trilliwon on 20/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

float rand(float2 p, float u_time) {
    float t = floor(u_time * 20.) / 10.;
    return fract(sin(dot(p, float2(t * 12.9898, t * 78.233))) * 43758.5453);
}

float noise(float2 uv, float blockiness, float u_time) {
    float2 lv = fract(uv);
    float2 id = floor(uv);
    float n1 = rand(id, u_time);
    float n2 = rand(id + float2(1, 0), u_time);
    float n3 = rand(id + float2(0, 1), u_time);
    float n4 = rand(id + float2(1, 1), u_time);
    float2 u = smoothstep(0.0, 1.0 + blockiness, lv);
    return mix(mix(n1, n2, u.x), mix(n3, n4, u.x), u.y);
}

float fbm(float2 uv, int count, float blockiness, float complexity, float u_time) {
    float val = 0.0;
    float amp = 0.5;

    while(count != 0) {
        val += amp * noise(uv, blockiness, u_time);
        amp *= 0.5;
        uv *= complexity;
        count--;
    }
    return val;
}

constant float glitchAmplitude = 0.1; // increase this
constant float glitchNarrowness = 4.0;
constant float glitchBlockiness = 2.0;
constant float glitchMinimizer = 5.0; // decrease this

fragment float4 glitchEffect(VertexIO inputFragment [[ stage_in ]],
                            texture2d<float> inputTexture [[ texture(0) ]],
                            constant CurrentTimeUniform& uniform [[ buffer(1) ]])
{

    float2 pos = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    float2 u_size = float2(1 / inputTexture.get_width(), 1 / inputTexture.get_height());

    float u_time = uniform.currentTime;

    float2 uv = pos;
    float2 a = float2(uv.x * (u_size.y / u_size.x), uv.y);
    float2 uv2 = float2(a.x * u_size.x, exp(a.y));

    // uv2 *= 2.;
    // Generate shift amplitude
    float shift = glitchAmplitude * pow(fbm(uv2, 4, glitchBlockiness, glitchNarrowness, u_time), glitchMinimizer);

    // Create a scanline effect
    float scanline = abs(cos(uv.y * 400.));
    scanline = smoothstep(0.0, 2.0, scanline);
    shift = smoothstep(0.00001, 0.2, shift);

    // Apply glitch and RGB shift
    float r = inputTexture.sample(textureSampler, float2(uv.x + shift, uv.y)).r * (1. - shift);
    float g = inputTexture.sample(textureSampler, float2(uv.x - shift, uv.y)).g * (1. - shift);
    float b = inputTexture.sample(textureSampler, float2(uv.x - shift, uv.y)).b * (1. - shift);

    // Mix with the scanline effect
    float3 f = float3(r, g, b) - (0.1 * scanline);

    return float4(f, 1.0);
}
