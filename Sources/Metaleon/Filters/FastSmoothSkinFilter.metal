//
//  FastSmoothSkinFilter.metal
//  Metaleon
//
//  Created by trilliwon on 27/05/2019.
//  Copyright © 2019 trilliwon. All rights reserfloatd.
//

#include <metal_stdlib>
#include "CommonOperationTypes.h"

using namespace metal;

// http://gamedev.stackexchange.com/a/59808
float3 rgb2hsv(float3 c) {
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = mix(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = mix(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float hsvSkin(float h, float s, float v) {
    float h1 = smoothstep(0.02, 0.03, h) * (1.0 - smoothstep(0.15, 0.20, h));
    float h2 = smoothstep(0.86, 0.90, h) * (1.0 - smoothstep(0.95, 0.97, h));
    float s1 = smoothstep(0.10, 0.15, s);
    float s2 = 1.0 - smoothstep(0.6, 0.8, s);
    float v1 = smoothstep(0.3, 0.5, v);
    return max(h1, h2) * s1 * s2 * v1;
}

fragment float4 fastSmoothSkinFilter(TwoInputVertexIO fragmentInput [[stage_in]],
                                    texture2d<float> inputTexture [[texture(0)]],
                                    texture2d<float> inputTextureSmooth [[texture(1)]],
                                    constant SmoothDegree& uniform [[ buffer(1) ]])
{
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    float2 pos = fragmentInput.textureCoordinate;
    float4 originColor = inputTexture.sample(textureSampler, pos).rgba;
    float4 smoothColor = inputTextureSmooth.sample(textureSampler, pos).rgba;
    float3 hsv = rgb2hsv(originColor.rgb);
    return mix(originColor, smoothColor, uniform.smoothDegree * hsvSkin(hsv.x, hsv.y, hsv.z));
}
