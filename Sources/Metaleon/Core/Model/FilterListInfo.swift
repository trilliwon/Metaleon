//
//  FilterListInfo.swift
//  Metaleon
//
//  Created by trilliwon on 24/06/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import Foundation

// Convert filter.json -> struct FitlerListInfo

public struct FilterListInfo: Codable {
    public let updated: String
    public let filters: [FilterInfo]
}

public struct FilterInfo: Codable {
    public let name: String
    public let desc: String
    public let thumbnail: String
    public let filterChainInfo: FilterChainInfo

    enum CodingKeys: String, CodingKey {
        case name, desc, thumbnail
        case filterChainInfo = "filterinfo"
    }
}

public struct FilterChainInfo: Codable {
    public let filterId   : String
    public let inputs     : [Input]
    public let adjustments: [Adjustment]
    public let parameters : [Parameter]
    public let chain      : [[String]]

    public struct Input: Codable {
        let id   : String
        let param: String
    }

    public struct Adjustment: Codable {
        let id    : String
        let module: String
        let params: [String]
    }

    public struct Parameter: Codable {
        let id  : String
        let name: String
    }
}
