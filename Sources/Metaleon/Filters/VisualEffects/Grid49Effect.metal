//
//  Grid49Effect.metal
//  Metaleon
//
//  Created by trilliwon on 17/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

fragment float4 grid49Effect(VertexIO       inputFragment [[stage_in]],
                            texture2d<float> inputTexture [[texture(0)]],
                            constant CurrentTimeUniform& uniform [[ buffer(1) ]] )
{
    float2 position = inputFragment.textureCoord;
    constexpr sampler textureSampler;

    float2 UV = position;
    float2 uv = UV - .5;

    float t = uniform.currentTime * 2;
    float scale = sin(t) * sin(t) * sin(t) * sin(t) * 2. + 1.;

    float2 suv = uv * scale;
    suv.y += abs(floor(suv.x + .5)) * .2 * scale;

    return inputTexture.sample(textureSampler, fract(suv + 0.5));
}
