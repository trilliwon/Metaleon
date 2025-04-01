//
//  VHSTapeEffect.metal
//  Metaleon
//
//  Created by trilliwon on 18/07/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;


constant float range = 0.01;
constant float noiseQuality = 250.0;
constant float noiseIntensity = 0.0099;
constant float offsetIntensity = 0.02;
constant float colorOffsetIntensity = 1.3;

float rand(float2 co)
{
    return fract(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

float verticalBar(float pos, float uvY, float offset)
{
    float edge0 = (pos - range);
    float edge1 = (pos + range);

    float x = smoothstep(edge0, pos, uvY) * offset;
    x -= smoothstep(pos, edge1, uvY) * offset;
    return x;
}

fragment float4 vhsTapeEffect(VertexIO inputFragment [[ stage_in ]],
                              texture2d<float> inputTexture [[ texture(0) ]],
                              constant CurrentTimeUniform& uniform [[ buffer(1) ]])
{
    float2 uv = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    float iTime = uniform.currentTime;

    for (float i = 0.0; i < 0.71; i += 0.1313) {
        float d = fmod(iTime * i, 1.7);
        float o = sin(1.0 - tan(iTime * 0.24 * i));
        o *= offsetIntensity;
        uv.x += verticalBar(d, uv.y, o);
    }

    float uvY = uv.y;
    uvY *= noiseQuality;
    uvY = float(int(uvY)) * (1.0 / noiseQuality);
    float noise = rand(float2(iTime * 0.00001, uvY));
    uv.x += noise * noiseIntensity;

    float2 offsetR = float2(0.006 * sin(iTime), 0.0) * colorOffsetIntensity;
    float2 offsetG = float2(0.0073 * (cos(iTime * 0.97)), 0.0) * colorOffsetIntensity;

    float r = inputTexture.sample(textureSampler, uv + offsetR).r;
    float g = inputTexture.sample(textureSampler, uv + offsetG).g;
    float b = inputTexture.sample(textureSampler, uv).b;

    return float4(r, g, b, 1.0);
}
