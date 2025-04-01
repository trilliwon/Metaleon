//
//  MirrorEffectFilter.swift
//  Metaleon
//
//  Created by trilliwon on 21/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import MetalKit

final public class MirrorEffectFilter: BasicRenderFilter {

    public init(type: MirrorType) {
        super.init(fragmentFuncName: .mirror)
        updateParameters(with: ["type" : type.rawValue])
    }
}

// MARK: - MirrorType
public extension MirrorEffectFilter {

    enum MirrorType: Float {
        case m2left = 0
        case m2bottom = 1
        case m2right = 2
        case m2top = 3
        case m4righttop = 4
        case m4rightbottom = 5
        case m4leftbottom = 6
        case m4lefttop = 7
    }
}
