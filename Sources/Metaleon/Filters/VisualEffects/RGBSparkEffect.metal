//
//  RGBSparkEffect.metal
//  Metaleon
//
//  Created by trilliwon on 20/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

fragment float4 rgbSparkEffect(VertexIO inputFragment [[ stage_in ]],
                              texture2d<float> inputTexture [[texture(0)]],
                              texture2d<float> inputTextureG [[texture(1)]],
                              texture2d<float> inputTextureB [[texture(2)]]) {

    float2 position = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    float r = inputTexture.sample(textureSampler, position).r;
    float g = inputTextureG.sample(textureSampler, position).g;
    float b = inputTextureB.sample(textureSampler, position).b;
    return float4(r, g, b,1.);
}
