//
//  FilterGenerator.swift
//  Metaleon
//
//  Created by trilliwon on 20/06/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import Foundation

public enum FilterGenerator {

    case byType(FilterInitializable.Type)

    static let defaultGenerators: [String: FilterGenerator] = [
        "alphablend"       : .byType(AlphaBlendFilter.self),
        "bilateral"        : .byType(BilateralFilter.self),
        "fastSmoothSkin"   : .byType(FastSmoothSkinFilter.self),
        "lookup"           : .byType(LookupFilter.self),
        "vignette"         : .byType(VignetteNormalFilter.self),
        "vignette_overlay" : .byType(VignetteOverlayFilter.self)
    ]
}
