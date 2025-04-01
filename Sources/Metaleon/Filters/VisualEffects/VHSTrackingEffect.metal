//
//  VHSTrackingEffect.metal
//  Metaleon
//
//  Created by trilliwon on 18/07/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

#include <metal_stdlib>
#include "../CommonOperationTypes.h"

using namespace metal;


#define INTERLACING_SEVERITY 0.001

#define TRACKING_HEIGHT 0.15
#define TRACKING_SEVERITY 0.025
#define TRACKING_SPEED 0.3

#define SHIMMER_SPEED 30.0

#define RGB_MASK_SIZE 2.0


fragment float4 vhsTrackingEffect(VertexIO inputFragment [[ stage_in ]],
                                  texture2d<float> inputTexture [[ texture(0) ]],
                                  constant CurrentTimeUniform& uniform [[ buffer(1) ]])
{
    float2 uv = inputFragment.textureCoord;
    float2 size = float2(inputTexture.get_width(), inputTexture.get_height());
    float2 frag = uv * size;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     filter::linear);

    float iTime = uniform.currentTime;

    // x wigglies (sampling error)
    uv.x -= sin(uv.y * 500.0 + iTime) * INTERLACING_SEVERITY;

    // Convert our xy coordinates into a linear index we can use in
    // the next step
    // periodically offset y by 1 pixel to get that shimmer
    float yOffset = floor(sin(iTime * SHIMMER_SPEED));
    float pix = (frag.y + yOffset) * size.x + frag.x;

    pix = floor(pix);

    // Simulate pixel layout by using a repeating RGB mask
    float4 colMask = float4(fmod(pix, RGB_MASK_SIZE), fmod((pix+1.0), RGB_MASK_SIZE), fmod((pix+2.0), RGB_MASK_SIZE), 1.0);
    colMask = colMask / (RGB_MASK_SIZE - 1.0) + 0.5;

    // Tracking
    float t = -iTime * TRACKING_SPEED;
    float fractionalTime = (t - floor(t)) * 1.3 - TRACKING_HEIGHT;

    if(fractionalTime + TRACKING_HEIGHT >= uv.y && fractionalTime <= uv.y)
    {
        uv.x -= fractionalTime * TRACKING_SEVERITY;
    }
    
    float scan = fmod(uv.y, 3.0);

    return inputTexture.sample(textureSampler, uv) * colMask;
}
