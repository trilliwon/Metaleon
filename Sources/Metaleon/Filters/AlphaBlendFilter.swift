//
//  AlphaBlendFilter.swift
//  Metaleon
//
//  Created by trilliwon on 22/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import UIKit

final class AlphaBlendFilter: BasicRenderFilter, ParamLessInitializable {

    init() {
        super.init(fragmentFuncName: .alphaBlend)
        updateParameters(with: ["alpha": 1.0])
    }
}
