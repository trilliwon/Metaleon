//
//  TileEffect.metal
//  Metaleon
//
//  Created by trilliwon on 21/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

float remap01(float a, float b, float t) {
    return clamp((t-a) / (b-a), 0., 1.);
}

float remap(float a, float b, float c, float d, float t){
    return remap01(a,b,t) * (d-c) + c;
}

fragment float4 tileEffect(VertexIO inputFragment [[ stage_in ]],
                          texture2d<float> inputTexture [[ texture(0) ]],
                          constant CurrentTimeUniform& uniform [[ buffer(1) ]])
{
    
    float2 pos = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);
    
    float cycleTime = 6.;
    float t = fmod(uniform.currentTime * 2., cycleTime);
    float scale = 1.;
    float2 tuv = pos;
    
    // phase 1
    if (t > 0.) {
        scale = remap(0., 0.5, 1., 2., t);
        tuv -= float2(1.0, 1.0);
    }
    
    // phase 2
    if (t > 2.) {
        scale = remap(2., 2.5, 2., 3., t);
        tuv -= float2(0.0, -1.0);
    }
    
    // phase 3
    if (t > 2.7) {
        scale = remap(2.7, 3.0, 3., 2., t);
        tuv -= float2(0.0, 1.0);
    }
    
    // phase 4
    if (t > 4.) {
        scale = remap(4., 4.5, 2., 3., t);
        tuv -= float2(.0, -1.0);
    }
    
    // phase 5
    if (t > 5.) {
        scale = remap(5., 6., 3., 1., t);
        tuv -= float2(.0, 1.0);
    }
    
    tuv = tuv * scale;
    
    float3 color = inputTexture.sample(textureSampler, fract(tuv)).rgb;
    return float4(color, 1.0);
}
