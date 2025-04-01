//
//  GridColorEffect.metal
//  Metaleon
//
//  Created by trilliwon on 21/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

fragment float4 gridColorEffect(VertexIO inputFragment [[ stage_in ]],
                               texture2d<float> inputTexture [[ texture(0) ]])
{
    float2 pos = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    float2 scaledCoord = pos * 3.0;
    float2 xy = fract(scaledCoord);
    float2 flooredCoord = floor(scaledCoord) * 0.5;
    float4 blueviolet = float4(0.54 * flooredCoord.x, 0.17 * (1.0 - flooredCoord.x), 0.78 * (1.0 - flooredCoord.y), 1.0);
    float4 tex = inputTexture.sample(textureSampler, xy).rgba;

    return float4(mix(tex, blueviolet, tex * 0.3));
}
