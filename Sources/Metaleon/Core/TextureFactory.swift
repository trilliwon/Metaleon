//
//  TextureFactory.swift
//  Metaleon
//
//  Created by trilliwon on 19/06/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import Metal
import UIKit

public protocol TextureFactory {
    func makeTexture(fileNamed name: String, flipped: Bool) -> MTLTexture?
}

public class BasicTextureFactory: TextureFactory {
    public var resourcePath: String?

    public init(resourcePath: String) {
        self.resourcePath = resourcePath
    }

    public func makeTexture(fileNamed name: String, flipped: Bool) -> MTLTexture? {
        guard let image = image(named: name) else { return nil }
        let texture = MetalDevice.shared.makeTexture(image: image)
        texture?.label = name
        return texture
    }

    private func image(named name: String) -> UIImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else {
            preconditionFailure("No image's path with - \(name)")
        }

        return UIImage(contentsOfFile: path)
    }
}
