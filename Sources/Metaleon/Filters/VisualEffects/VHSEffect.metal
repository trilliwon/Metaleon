//
//  VHSEffect.metal
//  Metaleon
//
//  Created by trilliwon on 18/07/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;

#define PI 3.14159265

float3 tex2D(float3 col, float2 _p ){
    if (0.5 < abs( _p.x - 0.5 ) ) {
        col = float3( 0.1 );
    }
    return col;
}

float hash( float2 _v ){
    return fract( sin( dot( _v, float2( 89.44, 19.36 ) ) ) * 22189.22 );
}

float iHash( float2 _v, float2 _r ){
    float h00 = hash( float2( floor( _v * _r + float2( 0.0, 0.0 ) ) / _r ) );
    float h10 = hash( float2( floor( _v * _r + float2( 1.0, 0.0 ) ) / _r ) );
    float h01 = hash( float2( floor( _v * _r + float2( 0.0, 1.0 ) ) / _r ) );
    float h11 = hash( float2( floor( _v * _r + float2( 1.0, 1.0 ) ) / _r ) );
    float2 ip = float2( smoothstep( float2( 0.0, 0.0 ), float2( 1.0, 1.0 ), fmod( _v * _r, 1. ) ) );
    return ( h00 * ( 1. - ip.x ) + h10 * ip.x ) * ( 1. - ip.y ) + ( h01 * ( 1. - ip.x ) + h11 * ip.x ) * ip.y;
}

float noise( float2 _v ){
    float sum = 0.;
    for( int i=1; i<9; i++ )
    {
        sum += iHash( _v + float2( i ), float2( 2. * pow( 2., float( i ) ) ) ) / pow( 2., float( i ) );
    }
    return sum;
}

fragment float4 vhsEffect(VertexIO inputFragment [[ stage_in ]],
                          texture2d<float> inputTexture [[ texture(0) ]],
                          constant CurrentTimeUniform& uniform [[ buffer(1) ]])
{
    float2 pos = inputFragment.textureCoord;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);
    float time = uniform.currentTime;
    float2 uvn = pos;
    float3 col = float3( 0.0 );

    // tape wave
    uvn.x += ( noise( float2( uvn.y, time ) ) - 0.5 ) * 0.005;
    uvn.x += ( noise( float2( uvn.y * 100.0, time * 10.0 ) ) - 0.5 ) * 0.01;

    // tape crease
    float tcPhase = clamp( ( sin( uvn.y * 8.0 - time * PI * 1.2 ) - 0.92 ) * noise( float2( time ) ), 0.0, 0.01 ) * 10.0;
    float tcNoise = max( noise( float2( uvn.y * 100.0, time * 10.0 ) ) - 0.5, 0.0 );
    uvn.x = uvn.x - tcNoise * tcPhase;

    // switching noise
    float snPhase = smoothstep( 0.03, 0.0, uvn.y );
    uvn.y += snPhase * 0.3;
    uvn.x += snPhase * ( ( noise( float2( pos.y * 100.0, time * 10.0 ) ) - 0.5 ) * 0.2 );

    col = inputTexture.sample(textureSampler, pos).rgb;
    col *= 1.0 - tcPhase;
    col = mix(col, col.yzx, snPhase);

    // bloom
//    for( float x = -4.0; x < 2.5; x += 1.0 ) {
        col.xyz += float3(inputTexture.sample(textureSampler, uvn + float2( -4 - 0.0, 0.0 ) * 7E-3).x,
                          inputTexture.sample(textureSampler, uvn + float2( -2, 0.0 ) * 7E-3).y,
                          inputTexture.sample(textureSampler, uvn + float2( -8.0, 0.0 ) * 7E-3).z) * 0.1;
//    }

    col *= 0.6;

    // ac beat
    col *= 1.0 + clamp(noise(float2(0.0, pos.y + time * 0.2)) * 0.6 - 0.25, 0.0, 0.1);

    return float4(col, 1.0);
}
