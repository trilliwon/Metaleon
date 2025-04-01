//
//  CommonOperationTypes.h
//  Metaleon
//
//  Created by trilliwon on 10/06/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//
#include <metal_stdlib>
using namespace metal;

#ifndef CommonOperationTypes_h
#define CommonOperationTypes_h

// Vertex input/output structure for passing results from vertex shader to fragment shader
struct VertexIO
{
    float4 position [[position]];
    float2 textureCoord [[user(texturecoord)]];
};

struct TwoInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
    float2 textureCoordinate2 [[user(texturecoord2)]];
};

// Fragment Uniform structs
typedef struct
{
    float alpha;
} AlphaUniform;

typedef struct
{
    float intensity;
} IntensityUniform;

typedef struct
{
    float smoothDegree;
} SmoothDegree;

typedef struct
{
    float currentTime;
} CurrentTimeUniform;

#endif /* CommonOperationTypes_h */
