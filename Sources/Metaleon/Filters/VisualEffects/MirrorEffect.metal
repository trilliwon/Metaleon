//
//  MirrorEffect.metal
//  Metaleon
//
//  Created by trilliwon on 21/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

typedef struct {
    float type;
} MirrorTypeUniform;

fragment float4 mirrorEffect(VertexIO inputFragment [[ stage_in ]],
                            texture2d<float> inputTexture [[ texture(0) ]],
                            constant MirrorTypeUniform& uniform [[ buffer(1) ]]) {

    float2 pos = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    int type = float(uniform.type);

    float2 uv = pos;
    float2 xy = pos;
    switch (type) {
        case 0:
            xy = float2(mix(uv.x + 0.25, 1. - uv.x + 0.25, step(0.5, uv.x)), uv.y); // m2left
            break;
        case 1:
            xy = float2(uv.x, mix(uv.y + 0.25, 1. - uv.y + 0.25, step(0.5, uv.y))); // m2bottom
            break;
        case 2:
            xy = float2(mix(1. - uv.x - 0.25, uv.x - 0.25, step(0.5, uv.x)), uv.y); // m2right
            break;
        case 3:
            xy = float2(uv.x, mix(1. - uv.y - 0.25, uv.y - 0.25, step(0.5, uv.y))); // m2top
            break;
        case 4:
            xy = mix(1. - uv - 0.25, uv - 0.25, step(0.5, uv)); // m4righttop
            break;
        case 5:
            xy = mix(1. - uv - 0.25, uv - 0.25, step(0.5, uv));
            xy.y = 1. - xy.y; // m4rightbottom
            break;
        case 6:
            xy = mix(uv + 0.25, 1. - uv + 0.25, step(0.5, uv)); // m4leftbottom
            break;
        case 7:
            xy = mix(uv + 0.25, 1. - uv + 0.25, step(0.5, uv));
            xy.y = 1. - xy.y; // m4lefttop
            break;
    }

    return inputTexture.sample(textureSampler, xy);
}
