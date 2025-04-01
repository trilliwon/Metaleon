//
//  SpringEffect.metal
//  Metaleon
//
//  Created by trilliwon on 20/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

constant float stepCount = 3.0;

fragment float4 springEffect(VertexIO inputFragment [[ stage_in ]],
                            texture2d<float> inputTexture [[ texture(0) ]],
                            constant CurrentTimeUniform& uniform [[ buffer(1) ]])
{
    float2 pos = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    float2 uv = pos - .5;
    float2 tc = uv;

    float t = uniform.currentTime * 1.8;
    float scale = min(abs(sin(t)), 0.8) * 0.3 + 1.0;

    float scaleGap = (scale - 1.0) / stepCount;

    while(scale > 1.0) {
        if(abs(uv * scale).x < .5 && abs(uv * scale).y < .5) {
            tc = uv * scale;
            break;
        }
        scale -= scaleGap;
    }

    tc += .5;

    return inputTexture.sample(textureSampler, tc);
}
