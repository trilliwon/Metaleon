//
//  LookupFilter.swift
//  Metaleon
//
//  Created by trilliwon on 16/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import UIKit

final class LookupFilter: BasicRenderFilter, ParamLessInitializable {

    init() {
        super.init(fragmentFuncName: .lookup)
        updateParameters(with: ["intensity": 0.5])
    }
}
