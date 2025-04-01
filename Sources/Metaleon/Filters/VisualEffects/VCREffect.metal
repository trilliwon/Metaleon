//
//  VCREffect.metal
//  Metaleon
//
//  Created by trilliwon on 18/07/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

constant float PI = 3.14159265;

float vcrEffectrand(float2 co) {
    return fract(sin(dot(co.xy ,float2(12.9898, 78.233))) * 43758.5453);
}

fragment float4 vcrEffect(VertexIO       inputFragment [[stage_in]],
                          texture2d<float> inputTexture [[texture(0)]],
                          constant CurrentTimeUniform& uniform [[ buffer(1) ]] )
{
    float2 uv = inputFragment.textureCoord;
//    float2 size = float2(inputTexture.get_width(), inputTexture.get_height());
//    float2 frag = uv * size;
    constexpr sampler textureSampler;

    float iTime = uniform.currentTime;

    //  wobble
    float2 wobbl = float2(0.003 * vcrEffectrand(float2(iTime, uv.y)), 0.);

    //  band distortion
    float t_val = tan(0.25 * iTime + uv.y * PI * .67);
    float2 tan_off = float2(wobbl.x * min(0., t_val), 0.);

    //  chromab
    float4 color1 = inputTexture.sample(textureSampler, uv + wobbl + tan_off);
    float4 color2 = inputTexture.sample(textureSampler, (uv + (wobbl * 1.5) + (tan_off * 1.3)) * 1.005);

    //  combine + grade
    float4 color = float4(color2.rg, pow(color1.b, .67), 1.);
    color.rgb = mix(inputTexture.sample(textureSampler, uv + tan_off).rgb, color.rgb, 0.5);

    //  scanline sim
    float s_val = ((sin(2. * PI * uv.y + iTime * 20.) + sin(2. * PI * uv.y)) / 2.)
    * .015 * sin(iTime);
    color += s_val;

    /*
     //  noise lines
     float ival = size.y / 4.;
     float r = vcrEffectrand(float2(iTime, frag.y));

     //  dirty hack to avoid conditional
     float on = floor(float(int(frag.y + (iTime * r * 1000.)) % int(ival + 1.)) / ival);
     */

    color = float4(min(1., color.r),
                   min(1., color.g),
                   min(1., color.b), 1.);

    float vig = 1. - sin(PI * uv.x) * sin(PI * uv.y);

    return color - (vig * 0.15);
}
