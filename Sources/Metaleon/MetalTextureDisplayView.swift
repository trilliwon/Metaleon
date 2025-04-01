//
//  MetalTextureDisplayView.swift
//  Metaleon
//
//  Created by trilliwon on 10/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import MetalKit

final public class MetalTextureDisplayView: MTKView {

    private var sourceTexture: MTLTexture?
    public var passThroughFilter = PassThroughFilter()

    private let syncQueue = DispatchQueue(
        label: "MetalTextureDisplayView",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem
    )

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: MetalDevice.shared.device)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.device = MetalDevice.shared.device
    }

    /// - Tag: DrawMetalTexture
    public override func draw(_ rect: CGRect) {
        var sourceTexture: MTLTexture?

        syncQueue.sync {
            sourceTexture = self.sourceTexture
        }

        guard let drawable = currentDrawable else { return }
        let destinationTexture = drawable.texture

        guard let commandBuffer = MetalDevice.shared.makeCommandBuffer() else { return }
        commandBuffer.label = description

        if let sourceTexture = sourceTexture {
            passThroughFilter.encode(
                to: commandBuffer,
                destinationTexture: destinationTexture,
                sourceTexture: sourceTexture
            )
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - Display texture
extension MetalTextureDisplayView {

    public func display(texture: MTLTexture) {
        sourceTexture = texture
    }
}
