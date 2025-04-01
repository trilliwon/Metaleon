//
//  FilterChain.swift
//  Metaleon
//
//  Created by trilliwon on 11/06/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import Metal

public class FilterChain {

    enum InputParamType: String {
        // texture input
        case texOrigin
        case lookup
        case texBlend

        // param
        case alpha
        case intensity
    }

    public let info: FilterInfo

    var filters: [String: Filter] = [:]
    var filterIds: [String] = []
    var staticInputTextures: [String: MTLTexture] = [:]
    var inputTextures: [String: [TextureIndex: String]] = [:]

    let chainInfos: [[String]]
    var parameterKey: String = "intensity"

    var count: Int {
        return filters.count
    }

    private let textureFactory: TextureFactory

    public init(info: FilterInfo, textureFactory: TextureFactory) {
        self.info = info
        self.chainInfos = info.filterChainInfo.chain
        self.textureFactory = textureFactory

        filters = setupFilters(chainInfo: self.info.filterChainInfo)
        filterIds = filters.keys.sorted()
        staticInputTextures = setupStaticTextures(chainInfo: self.info.filterChainInfo)
        inputTextures = setupInputTextures(chainInfo: self.info.filterChainInfo)
    }

    public func encode(to commandBuffer: MTLCommandBuffer, sourceTexture: MTLTexture) -> MTLTexture {

        var textureCache = ["in_1": sourceTexture]
        var output: MTLTexture?

        for filterId in filterIds {
            var textures = [TextureIndex: MTLTexture]()
            for (index, textureKey) in inputTextures[filterId] ?? [:] {
                textures[index] = textureCache[textureKey] ?? staticInputTextures[textureKey]
            }
            output = filters[filterId]?.encode(to: commandBuffer, inputTextures: textures)

            if filterId != filterIds.last, let output = output {
                textureCache[filterId] = MetalDevice.shared.copy(commandBuffer: commandBuffer, sourceTexture: output)
            }
        }

        textureCache = [:]
        return output ?? sourceTexture
    }

    /// Generate Filters from defulat filter types
    func setupFilters(chainInfo: FilterChainInfo) -> [String: Filter] {
        var filters: [String: Filter] = [:]

        for adj in chainInfo.adjustments {
            switch FilterGenerator.defaultGenerators[adj.module] {
            case let .byType(FilterType)?:
                filters[adj.id] = FilterType.init()
            default:
                continue
            }
        }
        return filters
    }

    func setupInputTextures(chainInfo: FilterChainInfo) -> [String: [TextureIndex: String]] {
        var inputTextures: [String: [TextureIndex: String]] = [:]
        for chain in chainInfo.chain {
            guard chain.count == 3 else {
                preconditionFailure("Invalid fitler chain info")
            }

            guard let paramType = InputParamType(rawValue: chain[2]) else { continue }

            if inputTextures[chain[1]] == nil {
                inputTextures[chain[1]] = [:]
            }

            switch paramType {
            case .texOrigin:
                inputTextures[chain[1]]?[0] = chain[0]
            case .lookup:
                inputTextures[chain[1]]?[1] = chain[0]
            case .texBlend:
                inputTextures[chain[1]]?[1] = chain[0]
            case .intensity:
                parameterKey = "intensity"
            case .alpha:
                parameterKey = "alpha"
            }
        }

        return inputTextures
    }

    /// Only consider as image textures
    func setupStaticTextures(chainInfo: FilterChainInfo) -> [String: MTLTexture] {
        var textures: [String: MTLTexture] = [:]
        for input in chainInfo.inputs {
            if input.param == "source" {
                continue
            } else {
                textures[input.id] = textureFactory.makeTexture(fileNamed: input.param, flipped: false)
            }
        }
        return textures
    }

    public func updateIntensity(with value: Float) {
        updateParameters(with: [parameterKey: value])
    }

    /// update parameter value, might be float type
    public func updateParameters(with parameters: [String: Float]) {
        for (key, value) in parameters {
            let chain: [String] = info.filterChainInfo.chain.first { $0[2] == key } ?? []
            if chain.count == 3 {
                let filterId = chain[1]
                filters.first(where: { $0.key == filterId })?.value.updateParameters(with: [key: value])
            }
        }
    }
}
