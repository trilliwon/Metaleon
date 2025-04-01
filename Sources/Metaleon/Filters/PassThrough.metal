/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 Pass-through shader (used for preview).
 */

#include <metal_stdlib>
#include "CommonOperationTypes.h"

using namespace metal;

// Vertex shader for a textured quad
vertex VertexIO vertexPassThrough(device packed_float4 *pPosition  [[ buffer(0) ]],
                                  device packed_float2 *pTexCoords [[ buffer(1) ]],
                                  uint                  vid        [[ vertex_id ]])
{
    VertexIO outVertex;

    outVertex.position = pPosition[vid];
    outVertex.textureCoord = pTexCoords[vid];

    return outVertex;
}

// Vertex shader for a textured quad
vertex TwoInputVertexIO TwoInputVertexPassThrough(device packed_float4 *pPosition  [[ buffer(0) ]],
                                                  device packed_float2 *pTexCoords [[ buffer(1) ]],
                                                  device packed_float2 *pTexCoords2 [[buffer(2)]],
                                                  uint                  vid        [[ vertex_id ]])
{
    TwoInputVertexIO outVertex;

    outVertex.position = pPosition[vid];
    outVertex.textureCoordinate = pTexCoords[vid];
    outVertex.textureCoordinate2 = pTexCoords2[vid];

    return outVertex;
}

// Fragment shader for a textured quad
fragment float4 fragmentPassThrough(VertexIO         inputFragment [[ stage_in ]],
                                   texture2d<float>  inputTexture  [[ texture(0) ]])
{
    constexpr sampler samplr(coord::normalized,
                             address::repeat,
                             filter::linear);
    return inputTexture.sample(samplr, inputFragment.textureCoord);
}
