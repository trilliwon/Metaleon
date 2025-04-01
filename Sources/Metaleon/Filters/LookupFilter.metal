//
//  LookupFilter.metal
//  Metaleon
//
//  Created by trilliwon on 10/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "CommonOperationTypes.h"

using namespace metal;

fragment float4 fragmentLookup(TwoInputVertexIO fragmentInput [[stage_in]],
                              texture2d<float> inputTexture [[texture(0)]],
                              texture2d<float> lookupTexture [[texture(1)]],
                              constant IntensityUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler(coord::normalized,
                                  address::repeat,
                                  filter::linear);

    float4 base = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    float blueColor = base.b * 63.0;

    float2 quad1;
    quad1.y = floor(floor(blueColor) / 8.0);
    quad1.x = floor(blueColor) - (quad1.y * 8.0);

    float2 quad2;
    quad2.y = floor(ceil(blueColor) / 8.0);
    quad2.x = ceil(blueColor) - (quad2.y * 8.0);

    float2 texPos1;
    texPos1.x = (quad1.x * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * base.r);
    texPos1.y = (quad1.y * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * base.g);

    float2 texPos2;
    texPos2.x = (quad2.x * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * base.r);
    texPos2.y = (quad2.y * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * base.g);

    float4 newColor1 = lookupTexture.sample(quadSampler, texPos1);
    float4 newColor2 = lookupTexture.sample(quadSampler, texPos2);

    float4 newColor = mix(newColor1, newColor2, fract(blueColor));
    return float4(mix(base, newColor, uniform.intensity));
}
