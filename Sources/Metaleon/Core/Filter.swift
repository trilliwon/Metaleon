//
//  Filter.swift
//  Metaleon
//
//  Created by trilliwon on 28/05/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import Metal

public typealias TextureIndex = Int

public protocol Filter: AnyObject {
    func updateParameters(with parameters: [String: Float])
    func encode(to commandBuffer: MTLCommandBuffer, inputTextures: [TextureIndex: MTLTexture]) -> MTLTexture
}

public protocol ParamLessInitializable {
    init()
}

public typealias FilterInitializable = Filter & ParamLessInitializable
