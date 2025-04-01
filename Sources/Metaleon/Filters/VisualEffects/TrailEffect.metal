//
//  TrailEffect.metal
//  Metaleon
//
//  Created by trilliwon on 20/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

constant float trailFactor = 10.0;

typedef struct
{
    float isFirstFrame;
} IsFirstFrameUniform;

fragment float4 trailEffect(VertexIO inputFragment [[ stage_in ]],
                           texture2d<float> inputTexture [[ texture(0) ]],
                           texture2d<float> inputTextureLast [[ texture(1) ]],
                           constant IsFirstFrameUniform& uniform [[ buffer(1) ]])
{
    float2 pos = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);
    float4 current = inputTexture.sample(textureSampler, pos).rgba;
    float4 last = inputTextureLast.sample(textureSampler, pos).rgba;

    float4 color = mix(current, (current + last * trailFactor) / (trailFactor + 1.0), uniform.isFirstFrame);
    return color;
}
