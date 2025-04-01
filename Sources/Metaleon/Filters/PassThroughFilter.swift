//
//  PassThroughFilter.swift
//  Metaleon
//
//  Created by trilliwon on 16/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import Foundation

final public class PassThroughFilter: BasicRenderFilter {

    init() {
        super.init(fragmentFuncName: .passThrough)
    }
}
