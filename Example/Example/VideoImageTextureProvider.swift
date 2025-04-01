//
//  VideoImageTextureProvider.swift
//  Metaleon
//
//  Created by trilliwon on 16/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import AVFoundation
import UIKit

protocol VideoImageTextureProviderDelegate: AnyObject {
    func videoImageTextureProvider(_: VideoImageTextureProvider, currentTime: CMTime, didProvideTexture texture: MTLTexture)
}

class VideoImageTextureProvider: NSObject {

    var textureCache: CVMetalTextureCache?
    let captureSession = AVCaptureSession()
    let sampleBufferCallbackQueue = DispatchQueue(label: "MetalImageFilterQueue")
    weak var delegate: VideoImageTextureProviderDelegate?

    /// Returns an initialized VideoImageTextureProvider object with an associated Metal device and delegate, or nil in case of failure.
    required init?(device: MTLDevice, delegate: VideoImageTextureProviderDelegate) {
        super.init()

        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        self.delegate = delegate

        // Class initialization fails if the capture session could not be initialized.
        if !didInitializeCaptureSession() {
            return nil
        }
    }

    var videoDevice: AVCaptureDevice?

    /// Attempts to initialize a capture session.
    func didInitializeCaptureSession() -> Bool {

        /* The capture session preset is fixed at a 960x540 pixel resolution that matches the MTKView pixel resolution.
         This ensures screen size compatibility with all target iOS devices, without having to downsample or transform the video image.
         */
        captureSession.sessionPreset = AVCaptureSession.Preset.high

        // Use a guard to ensure the method can access a video capture device with a given camera position

        guard let camera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.front) else {
            print("Unable to access camera.")
            return false
        }

        videoDevice = camera

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                print("Unable to add camera input.")
                return false
            }
        } catch {
            print("Error accessing camera input: \(error)")
            return false
        }

        /* Creates a video data output object with a 32-bit BGRA pixel format.
         Setting self to the output object's sample buffer delegate allows this class to respond to every
         frame update.
         */
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoOutput.setSampleBufferDelegate(self, queue: sampleBufferCallbackQueue)

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            print("Unable to add camera input.")
            return false
        }
        return true
    }

    // MARK: Capture Session Controls
    func startRunning() {
        sampleBufferCallbackQueue.async {
            self.captureSession.startRunning()
            self.setExposure(value: 0.5)
        }
    }

    func stopRunning() {
        captureSession.stopRunning()
    }

    func setExposure(value: Float) {
        guard let device = videoDevice else { return }

        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            let ratio = 1.0 - value
            let minBias = device.minExposureTargetBias * 0.4
            let maxBias = device.maxExposureTargetBias * 0.4
            let bias = minBias + (maxBias - minBias) * ratio
            device.setExposureTargetBias(bias, completionHandler: nil)
        } catch {
            print(error)
        }
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

/// Having the VideoImageTextureProvider class conform to the AVCaptureVideoDataOutputSampleBufferDelegate protocol
/// and be the video output object's sample buffer delegate allows it to respond to every video capture frame update.
extension VideoImageTextureProvider: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            connection.videoOrientation = AVCaptureVideoOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!
        }

        guard
            let cameraTextureCache = textureCache,
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else {
            return
        }

        /** Given a pixel buffer, the following code populates a Metal texture with the contents of the captured video frame.
         */
        var cameraTexture: CVMetalTexture?
        let cameraTextureWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
        let cameraTextureHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, cameraTextureCache, pixelBuffer, nil, MTLPixelFormat.bgra8Unorm, cameraTextureWidth, cameraTextureHeight, 0, &cameraTexture)
        if let cameraTexture = cameraTexture, let metalTexture = CVMetalTextureGetTexture(cameraTexture) {
            // Call the delegate method whenever a new video frame has been converted into a Metal texture
            delegate?.videoImageTextureProvider(self, currentTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer), didProvideTexture: metalTexture)
        }
    }
}
