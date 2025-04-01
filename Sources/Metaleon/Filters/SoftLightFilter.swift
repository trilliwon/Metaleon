//
//  SoftLightFilter.swift
//  Metaleon
//
//  Created by trilliwon on 22/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import UIKit

final class SoftLightFilter: BasicRenderFilter {

    init() {
        super.init(fragmentFuncName: .softLight)
        updateParameters(with: ["alpha" : 1.0])
    }
}
