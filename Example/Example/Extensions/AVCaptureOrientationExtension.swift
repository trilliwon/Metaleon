//
//  AVCaptureOrientationExtension.swift
//  Metaleon
//
//  Created by trilliwon on 07/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import AVFoundation
import UIKit

extension AVCaptureVideoOrientation {
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}
