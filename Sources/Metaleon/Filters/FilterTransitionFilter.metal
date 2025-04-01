//
//  FilterTransitionFilter.metal
//  Metaleon
//
//  Created by trilliwon on 21/05/2019.
//  Copyright © 2019 kakakocorp. All rights reserved.
//

#include <metal_stdlib>
#include "CommonOperationTypes.h"

using namespace metal;

typedef struct {
    float edge;
} EdgeUniform;

fragment float4 filterTransitionFilter(VertexIO inputFragment [[ stage_in ]],
                                      texture2d<float> inputTexture [[ texture(0) ]],
                                      texture2d<float> inputTextureLast [[ texture(1) ]],
                                      constant EdgeUniform& uniform [[ buffer(1) ]])
{
    float2 pos = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    if ( pos.x < uniform.edge ) {
        return inputTexture.sample(textureSampler, pos).rgba;
    } else {
        return inputTextureLast.sample(textureSampler, pos).rgba;
    }
}
