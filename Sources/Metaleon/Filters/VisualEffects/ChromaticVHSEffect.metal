//
//  ChromaticVHSEffect.metal
//  Metaleon
//
//  Created by trilliwon on 18/07/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

#define VHS 1

fragment float4 chromaticVHSEffect(VertexIO       inputFragment [[stage_in]],
                                   texture2d<float> inputTexture [[texture(0)]],
                                   constant CurrentTimeUniform& uniform [[ buffer(1) ]] )
{
    float2 uv = inputFragment.textureCoord;
    constexpr sampler textureSampler;

    float iTime = uniform.currentTime;
    float amount = sin(iTime) * 0.1;

#if VHS
    amount *= 0.3;
    float split = 1. - fract(iTime / 2.);
    float scanOffset = 0.01;
    float2 uv1 = float2(uv.x + amount, uv.y);
    float2 uv2 = float2(uv.x, uv.y + amount);
    if (uv.y > split) {
        uv.x += scanOffset;
        uv1.x += scanOffset;
        uv2.x += scanOffset;
    }
#else
    // center
    float2 p = float2(0.5, 0.5);

    // take the current uv and offset by variance
    float2 dir = normalize(p - uv);

    // smoothstep for lens effect
    float strength = smoothstep(0.2, 1., distance(p, uv));
    float2 var = amount * dir * strength;

    // add this to the uv
    float2 uv1 = uv + (var*0.5);

    // add twice for channel 2
    float2 uv2 = uv1 + (var*0.5);
#endif

    float r = inputTexture.sample(textureSampler, uv1).r;
    float g = inputTexture.sample(textureSampler, uv).g;
    float b = inputTexture.sample(textureSampler, uv2).b;

    return float4(r, g, b, 1.);
}
