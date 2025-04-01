//
//  OldFilmEffect.metal
//  Metaleon
//
//  Created by trilliwon on 18/07/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;


#define SEQUENCE_LENGTH 24.0
#define FPS 12.

float4 vignette(float2 uv, float time)
{
    uv *=  1.0 - uv.yx;
    float vig = uv.x*uv.y * 15.0;
    float t = sin(time * 23.) * cos(time * 8. + .5);
    vig = pow(vig, 0.4 + t * .05);
    return float4(vig);
}

float easeIn(float t0, float t1, float t)
{
    return 2.0*smoothstep(t0,2.*t1-t0,t);
}

float4 blackAndWhite(float4 color)
{
    return float4(dot(color.xyz, float3(.299, .587, .114)));
}

float4 jumpCut(float seqTime)
{
    float toffset = 0.;
    float3 camoffset = float3(0.);

    float jct = seqTime;
    float jct1 = 7.7;
    float jct2 = 8.2;
    float jc1 = step( jct1, jct );
    float jc2 = step( jct2, jct );

    camoffset += float3(.8,.0,.0) * jc1;
    camoffset += float3(-.8,0.,.0) * jc2;

    toffset += 0.8 * jc1;
    toffset -= (jc2-jc1)*(jct-jct1);
    toffset -= 0.9 * jc2;

    return float4(camoffset, toffset);
}

float limitFPS(float time, float fps)
{
    time = fmod(time, SEQUENCE_LENGTH);
    return float(int(time * fps)) / fps;
}

float2 moveImage(float2 uv, float time)
{
    uv.x += .002 * (cos(time * 3.) * sin(time * 12. + .25));
    uv.y += .002 * (sin(time * 1. + .5) * cos(time * 15. + .25));
    return uv;
}


fragment float4 oldFilmEffect(VertexIO       inputFragment [[stage_in]],
                              texture2d<float> inputTexture [[texture(0)]],
                              constant CurrentTimeUniform& uniform [[ buffer(1) ]] )
{
    float2 uv = inputFragment.textureCoord;
    constexpr sampler textureSampler;

    float iTime = uniform.currentTime;

    float2 qq = -1.0 + 2.0 * uv;
    qq.x *= uv.x / uv.y;

    float time = limitFPS(iTime, FPS);

//    float4 jumpCutData = jumpCut(time);
    float4 image = inputTexture.sample(textureSampler, moveImage(uv, time));
    float4 vig = vignette(uv, time);

    float4 fragColor = image * vig;
    return blackAndWhite(fragColor);
}
