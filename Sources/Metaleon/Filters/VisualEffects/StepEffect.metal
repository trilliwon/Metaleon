//
//  StepEffect.metal
//  Metaleon
//
//  Created by trilliwon on 20/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

float4 rgb2gray_(float4 color) {
    return float4(float3(clamp((color.b * 0.45703125 + color.g * 2.34765625 + color.r * 1.1953125) / 4.0, 0.0, 1.0)) ,1.0);
}

typedef struct
{
    float activeStep;
} ActiveStepUniform;

fragment float4 stepVerticalEffect(VertexIO inputFragment [[ stage_in ]],
                                  texture2d<float> inputTexture [[ texture(0) ]],
                                  texture2d<float> inputTexture1 [[ texture(1) ]],
                                  texture2d<float> inputTexture2 [[ texture(2) ]],
                                  constant ActiveStepUniform& uniform [[ buffer(1) ]])
{
    float2 pos = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    int activeStep = int(uniform.activeStep);

    if (pos.x < 0.33) {
        float x = pos.x + 1. / 3.;
        float2 v = float2(x, pos.y);
        float4 c = inputTexture.sample(textureSampler, v).rgba;
        if (activeStep != 0) {
            c = rgb2gray_(c);
        }
        return c;
    } else if (pos.x < 0.67) {
        float4 c = inputTexture1.sample(textureSampler, pos).rgba;
        if (activeStep != 1) {
            c = rgb2gray_(c);
        }
        return c;
    } else {
        float x = pos.x - 1. / 3.;
        float2 v = float2(x, pos.y);
        float4 c = inputTexture2.sample(textureSampler, v).rgba;
        if (activeStep != 2) {
            c = rgb2gray_(c);
        }
        return c;
    }
}

fragment float4 stepHorizontalEffect(VertexIO inputFragment [[ stage_in ]],
                                    texture2d<float> inputTexture [[ texture(0) ]],
                                    texture2d<float> inputTexture1 [[ texture(1) ]],
                                    texture2d<float> inputTexture2 [[ texture(2) ]],
                                    constant ActiveStepUniform& uniform [[ buffer(1) ]])
{
    float2 pos = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    int activeStep = int(uniform.activeStep);
    if (pos.y < 0.33) {
        float y = pos.y + 1./3.;
        float2 v = float2(pos.x, y);
        float4 c = inputTexture.sample(textureSampler, v).rgba;
        if (activeStep != 0) {
            c = rgb2gray_(c);
        }
        return c;
    } else if (pos.y < 0.67) {
        float4 c = inputTexture1.sample(textureSampler, pos).rgba;
        if (activeStep != 1) {
            c = rgb2gray_(c);
        }
        return c;
    } else {
        float y = pos.y - 1./3.;
        float2 v = float2(pos.x, y);
        float4 c = inputTexture2.sample(textureSampler, v).rgba;
        if (activeStep != 2) {
            c = rgb2gray_(c);
        }
        return c;
    }
}
