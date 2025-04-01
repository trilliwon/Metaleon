//
//  MTLTextureExtensions.swift
//  Metaleon
//
//  Created by trilliwon on 10/07/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import Metal

extension MTLTexture {

    var texture2DDescriptor: MTLTextureDescriptor {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: width, height: height, mipmapped: mipmapLevelCount != 1)
        textureDescriptor.storageMode = .private
        textureDescriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        return textureDescriptor
    }
}
