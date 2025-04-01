//
//  GridColorEffectFilter.swift
//  Metaleon
//
//  Created by trilliwon on 21/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import MetalKit

final public class GridColorEffectFilter: BasicRenderFilter {

    public init() {
        super.init(fragmentFuncName: .gridColor)
    }
}
