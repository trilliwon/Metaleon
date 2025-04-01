//
//  RGBShiftEdgeEffect.metal
//  Metaleon
//
//  Created by trilliwon on 18/07/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

constant float RADIUS = 0.9;
constant float SOFTNESS = 0.8;

fragment float4 rgbShiftEdgeEffect(VertexIO inputFragment [[ stage_in ]],
                                   texture2d<float> inputTexture [[ texture(0) ]],
                                   constant CurrentTimeUniform& uniform [[ buffer(1) ]])
{
    float2 uv = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    float2 position = uv / float2(0.6,1.0) - float2(0.8,0.5) ;
    float len = length(position);
    float vignette = 1.0 - smoothstep(RADIUS, RADIUS - SOFTNESS, len);

    float colorR = inputTexture.sample(textureSampler, uv - (vignette * (position * (len * 0.015)))).r;
    float colorG = inputTexture.sample(textureSampler, uv).g;
    float colorB = inputTexture.sample(textureSampler, uv + (vignette * (position * (len * 0.015)))).b;

    return float4(colorR, colorG, colorB, 1.0);
}
