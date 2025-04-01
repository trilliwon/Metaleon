//
//  MTLBufferExtensions.swift
//  Metaleon
//
//  Created by trilliwon on 31/05/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import Metal

extension MTLBuffer {

    func update(value: Float) {
        var value = value
        let bufferPointer = self.contents()
        memcpy(bufferPointer, &value, MemoryLayout<Float>.size)
    }

    func update(values: [Float]) {
        var values = values
        let bufferPointer = self.contents()
        memcpy(bufferPointer, &values, values.count * MemoryLayout<Float>.size)
    }
}
