//
//  FilterStorage.swift
//  Metaleon
//
//  Created by trilliwon on 21/05/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import UIKit
import Metaleon

class FilterStorage {

    static let shared = FilterStorage()
    var filterChainList: [FilterChain] = []

    let textureFactory: BasicTextureFactory

    init(jsonFilePath: String = FilePath.filterJSON, filterLookupFilePath: String = FilePath.filterLookup) {
        let filterListInfo = FilterStorage.filterInfoWithContentsOfFile(path: jsonFilePath)
        textureFactory = BasicTextureFactory(resourcePath: filterLookupFilePath)

        for filterInfo in filterListInfo.filters {
            filterChainList.append(FilterChain(info: filterInfo, textureFactory: textureFactory))
        }
    }

    private enum FilePath {
        static let filterDirectory = ""
        static let filterJSON = filterDirectory + "filter.json"
        static let filterLookup = filterDirectory + "lookup"
    }

    private static func filterInfoWithContentsOfFile(path: String) -> FilterListInfo {
        guard let path = Bundle.main.path(forResource: path, ofType: nil) else {
            preconditionFailure("no path")
        }

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            preconditionFailure("no data")
        }

        guard let filterInfo = try? JSONDecoder().decode(FilterListInfo.self, from: data) else {
            preconditionFailure("decode error")
        }
        return filterInfo
    }
}
