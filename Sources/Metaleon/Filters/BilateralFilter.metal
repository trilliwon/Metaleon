//
//  BilateralFilter.metal
//  Metaleon
//
//  Created by trilliwon on 24/05/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

constant int sampleCount = 9;
constant int samplefloatCount = sampleCount / 2;

// from a vertex shader to a fragment shader
struct VertexOutput
{
    float4 position [[position]];

    float2 textureCoordTopLeft [[user(textureCoord0)]];
    float2 textureCoordTop [[user(textureCoord1)]];
    float2 textureCoordTopRight [[user(textureCoord2)]];

    float2 textureCoordLeft [[user(textureCoord3)]];
    float2 textureCoord [[user(textureCoord4)]];
    float2 textureCoordRight [[user(textureCoord5)]];

    float2 textureCoordBottomLeft [[user(textureCoord6)]];
    float2 textureCoordBottom [[user(textureCoord7)]];
    float2 textureCoordBottomRight [[user(textureCoord8)]];

    /*
     .______________.
     |    |    |    |
     .____.____.____.
     |    |    |    |
     .____.____.____.
     |    |    |    |
     .____.____.____.
     */
};

struct VertexInput
{
    float4 position [[position]];
    float2 textureCoord [[user(texturecoord)]];
};

float2 blurStep(float num, float2 texelOffset) {
    float multiplier = float(num - samplefloatCount);
    float2 blurStep = multiplier * texelOffset;
    return blurStep;
}

typedef struct {
    float2 texelOffset;
} TexelOffsetUniform;

// Vertex shader for a textured quad
vertex VertexOutput linearNearByVertex(device packed_float4 *pPosition  [[ buffer(0) ]],
                                       device packed_float2 *pTexCoords [[ buffer(1) ]],
                                       constant TexelOffsetUniform& uniform [[ buffer(2) ]],
                                       uint                  vid        [[ vertex_id ]])
{
    VertexOutput outVertex;

    outVertex.position = pPosition[vid];

    outVertex.textureCoordTopLeft     = pTexCoords[vid] + blurStep(0, uniform.texelOffset);
    outVertex.textureCoordTop         = pTexCoords[vid] + blurStep(1, uniform.texelOffset);
    outVertex.textureCoordTopRight    = pTexCoords[vid] + blurStep(2, uniform.texelOffset);
    outVertex.textureCoordLeft        = pTexCoords[vid] + blurStep(3, uniform.texelOffset);
    outVertex.textureCoord            = pTexCoords[vid] + blurStep(4, uniform.texelOffset);
    outVertex.textureCoordRight       = pTexCoords[vid] + blurStep(5, uniform.texelOffset);
    outVertex.textureCoordBottomLeft  = pTexCoords[vid] + blurStep(6, uniform.texelOffset);
    outVertex.textureCoordBottom      = pTexCoords[vid] + blurStep(7, uniform.texelOffset);
    outVertex.textureCoordBottomRight = pTexCoords[vid] + blurStep(8, uniform.texelOffset);

    return outVertex;
}

typedef struct {
    float normalizationFactor;
} NormalizationFactorUniform;


fragment float4 bilateralFragment(VertexOutput inputFragment      [[ stage_in ]],
                                 texture2d<float> inputTexture    [[ texture(0) ]],
                                 constant NormalizationFactorUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler samplr(coord::normalized,
                             address::repeat,
                             filter::linear);

    // Center
    float4 centralColor = inputTexture.sample(samplr, inputFragment.textureCoord);
    float gaussianWeightTotal = 0.18;
    float4 sum = centralColor * gaussianWeightTotal;

    float4 sampleColor;
    float distanceFromCentralColor;
    float gaussianWeight;
    float normalizationFactor = float(uniform.normalizationFactor);

    sampleColor = inputTexture.sample(samplr, inputFragment.textureCoordTopLeft);
    float dis = distance(centralColor, sampleColor) * normalizationFactor;
    distanceFromCentralColor = min(dis, 1.0);
    gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = inputTexture.sample(samplr, inputFragment.textureCoordTop);
    dis = distance(centralColor, sampleColor) * normalizationFactor;
    distanceFromCentralColor = min(dis, 1.0);
    gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = inputTexture.sample(samplr, inputFragment.textureCoordTopRight);
    dis = distance(centralColor, sampleColor) * normalizationFactor;
    distanceFromCentralColor = min(dis, 1.0);
    gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = inputTexture.sample(samplr, inputFragment.textureCoordLeft);
    dis = distance(centralColor, sampleColor) * normalizationFactor;
    distanceFromCentralColor = min(dis, 1.0);
    gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = inputTexture.sample(samplr, inputFragment.textureCoordRight);
    dis = distance(centralColor, sampleColor) * normalizationFactor;
    distanceFromCentralColor = min(dis, 1.0);
    gaussianWeight = 0.15 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = inputTexture.sample(samplr, inputFragment.textureCoordBottomLeft);
    dis = distance(centralColor, sampleColor) * normalizationFactor;
    distanceFromCentralColor = min(dis, 1.0);
    gaussianWeight = 0.12 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = inputTexture.sample(samplr, inputFragment.textureCoordBottom);
    dis = distance(centralColor, sampleColor) * normalizationFactor;
    distanceFromCentralColor = min(dis, 1.0);
    gaussianWeight = 0.09 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    sampleColor = inputTexture.sample(samplr, inputFragment.textureCoordBottomRight);
    dis = distance(centralColor, sampleColor) * normalizationFactor;
    distanceFromCentralColor = min(dis, 1.0);
    gaussianWeight = 0.05 * (1.0 - distanceFromCentralColor);
    gaussianWeightTotal += gaussianWeight;
    sum += sampleColor * gaussianWeight;

    return sum / gaussianWeightTotal;
}
