//
//  VignetteFilter.swift
//  Metaleon
//
//  Created by trilliwon on 27/05/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import Foundation

class VignetteFilter: BasicRenderFilter {

    enum VignetteFilterFuncType {
        case normal, softLight, overlay, multiply, colorBurn

        var fragmentShaderFuncName: ShaderFuncName.Fragment {
            switch self {
            case .normal:
                return .vignetteNormal
            case .softLight:
                return .vignetteSoftLight
            case .overlay:
                return .vignetteOverlay
            case .multiply:
                return .vignetteMultiply
            case .colorBurn:
                return .vignetteColorBurn
            }
        }
    }

    init(type: VignetteFilterFuncType = .normal) {
        super.init(fragmentFuncName: type.fragmentShaderFuncName)
        updateParameters(with: ["alpha": 1.0])
    }
}

class VignetteNormalFilter: VignetteFilter, ParamLessInitializable {

    required init() {
        super.init(type: .normal)
    }
}

class VignetteSoftLightFilter: VignetteFilter, ParamLessInitializable {

    required init() {
        super.init(type: .softLight)
    }
}

class VignetteOverlayFilter: VignetteFilter, ParamLessInitializable {

    required init() {
        super.init(type: .overlay)
    }
}

class VignetteMultiplyFilter: VignetteFilter, ParamLessInitializable {

    required init() {
        super.init(type: .multiply)
    }
}

class VignetteColorBurnFilter: VignetteFilter, ParamLessInitializable {

    required init() {
        super.init(type: .colorBurn)
    }
}
