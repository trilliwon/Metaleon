//
//  MetalDevice.swift
//  Metaleon
//
//  Created by trilliwon on 29/05/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import Metal
import MetalKit

final public class MetalDevice {
    
    public static let shared = MetalDevice()

    public let device: MTLDevice

    let commandQueue: MTLCommandQueue
    let defaultLibrary: MTLLibrary
    let fence: MTLFence

    private(set) var creationHeap: MTLHeap?
    private(set) var copyHeap: MTLHeap?

    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            preconditionFailure("Unable to create metal device")
        }
        self.device = device

        guard let commandQueue = device.makeCommandQueue() else {
            preconditionFailure("Unable to create commandQueue")
        }
        self.commandQueue = commandQueue

        guard let libary = try? device.makeDefaultLibrary(bundle: .module) else {
            preconditionFailure("Unable to create default libary, may be there is no metal functions")
        }

        guard let fence = device.makeFence() else {
            preconditionFailure("Unable to create fence")
        }
        self.fence = fence
        self.defaultLibrary = libary
    }
}

public extension MetalDevice {

    func makeCommandBuffer() -> MTLCommandBuffer? {
        return commandQueue.makeCommandBuffer()
    }

    func makeBuffer(length: Int, options: MTLResourceOptions = []) -> MTLBuffer? {
        return device.makeBuffer(length: length, options: options)
    }

    func makeHeap(textureDescriptor: MTLTextureDescriptor) -> MTLHeap? {
        let sizeAndAlgin = device.heapTextureSizeAndAlign(descriptor: textureDescriptor)
        let heapDescriptor = MTLHeapDescriptor()
        heapDescriptor.cpuCacheMode = .defaultCache
        heapDescriptor.storageMode = .private
        heapDescriptor.size = sizeAndAlgin.size
        let heap = device.makeHeap(descriptor: heapDescriptor)
        heap?.label = "Shared Heap"
        return heap
    }

    func makeTexture(image: UIImage?) -> MTLTexture? {
        do {
            guard let cgImage = image?.cgImage else { return nil }
            return try MTKTextureLoader(device: device).newTexture(cgImage: cgImage, options: [MTKTextureLoader.Option.SRGB : false])
        } catch {
            return nil
        }
    }

    func makeTexture(descriptor: MTLTextureDescriptor) -> MTLTexture? {
        return device.makeTexture(descriptor: descriptor)
    }

    func makeTextureFromCreationHeap(descriptor: MTLTextureDescriptor) -> MTLTexture? {

        let texture: MTLTexture?

        if let heap = creationHeap {
            texture = heap.makeTexture(descriptor: descriptor)
            texture?.makeAliasable()
        } else {
            if let textureHeap = makeHeap(textureDescriptor: descriptor) {
                self.creationHeap = textureHeap
                texture = self.creationHeap?.makeTexture(descriptor: descriptor)
                texture?.makeAliasable()
            } else {
                texture = device.makeTexture(descriptor: descriptor)
            }
        }

        return texture
    }

    func makeRenderPipelineState(vertextFuncName: String, fragmentFuncName: String) -> (MTLRenderPipelineState?, [MTLArgument]) {

        // Retrieve the shader functions
        let vertexFunction = defaultLibrary.makeFunction(name: vertextFuncName)
        vertexFunction?.label = vertextFuncName
        let fragmentFunction = defaultLibrary.makeFunction(name: fragmentFuncName)
        fragmentFunction?.label = fragmentFuncName

        // Create the renderPiplineDescriptor
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction

        // https://developer.apple.com/documentation/metal/mtlrenderpipelinereflection
        // Avoid obtaining reflection data if it will not be used.
        var reflection: MTLAutoreleasedRenderPipelineReflection?

        // Create the PipelineState and obtain arguments info
        do {
            let renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor, options: [.bufferTypeInfo, .argumentInfo], reflection: &reflection)
            return (renderPipelineState, reflection?.fragmentArguments ?? [])
        } catch {
            print("Could not create render pipeline state: \(error)")
            return (nil, [])
        }
    }

    func makeDefaultVertexCoodBuffers() -> MTLBuffer? {
        // Vertex coordinate takes the gravity into account.

        let vertexData: [Position] = [
            Position(x: -1.0, y: -1.0, z: 0.0, w: 1.0),
            Position(x:  1.0, y: -1.0, z: 0.0, w: 1.0),
            Position(x: -1.0, y:  1.0, z: 0.0, w: 1.0),
            Position(x:  1.0, y:  1.0, z: 0.0, w: 1.0)
        ]

        return device.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Position>.stride, options: [])
    }

    func makeDefaultTextureCoodBuffer() -> MTLBuffer? {
        // Texture coordinate takes the rotation into account.
        let textData: [Float] = [
            0.0, 1.0,
            1.0, 1.0,
            0.0, 0.0,
            1.0, 0.0
        ]

        return device.makeBuffer(bytes: textData, length: textData.count * MemoryLayout<Float>.size, options: [])
    }

    func makeAspectFillVertextCoodBuffers(bounds: CGRect, textureWidth: Int, textureHeight: Int, textureMirroring: Bool) -> MTLBuffer? {
        let textureWidth = textureWidth
        let textureHeight = textureHeight
        let bounds = bounds
        var scaleX: Float = 1.0
        var scaleY: Float = 1.0

        scaleX = Float(bounds.width / CGFloat(textureWidth))
        scaleY = Float(bounds.height / CGFloat(textureHeight))

        if scaleX < scaleY {
            scaleY = scaleX / scaleY
            scaleX = 1.0
        } else {
            scaleX = scaleY / scaleX
            scaleY = 1.0
        }

        if textureMirroring {
            scaleX *= -1.0
        }

        // Vertex coordinate takes the gravity into account.
        let vertexData: [Position] = [
            Position(x: -scaleX, y: -scaleY, z: 0.0, w: 1.0),
            Position(x:  scaleX, y: -scaleY, z: 0.0, w: 1.0),
            Position(x: -scaleX, y:  scaleY, z: 0.0, w: 1.0),
            Position(x:  scaleX, y:  scaleY, z: 0.0, w: 1.0)
        ]

        return device.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Position>.stride, options: [])
    }

    func copy(commandBuffer: MTLCommandBuffer, sourceTexture: MTLTexture) -> MTLTexture {

        var copiedTexture: MTLTexture

        if let toTexture = copyHeap?.makeTexture(descriptor: sourceTexture.texture2DDescriptor) {
            copiedTexture = toTexture
            copiedTexture.makeAliasable()
        } else {
            guard let toTexture = device.makeTexture(descriptor: sourceTexture.texture2DDescriptor) else {
                preconditionFailure("Failed making texture for copying")
            }
            copiedTexture = toTexture
        }

        if let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder() {
            blitCommandEncoder.waitForFence(fence)
            blitCommandEncoder.copy(from: sourceTexture,
                                    sourceSlice: 0,
                                    sourceLevel: 0,
                                    sourceOrigin: MTLOriginMake(0, 0, 0),
                                    sourceSize: MTLSize(width: sourceTexture.width, height: sourceTexture.height, depth: 1),
                                    to: copiedTexture,
                                    destinationSlice: 0,
                                    destinationLevel: 0,
                                    destinationOrigin: MTLOriginMake(0, 0, 0))
            blitCommandEncoder.updateFence(fence)
            blitCommandEncoder.endEncoding()
        }
        return copiedTexture
    }
}
