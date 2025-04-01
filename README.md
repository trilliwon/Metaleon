# Metaleon

![Metal](https://img.shields.io/badge/Metal-iOS-blue)
![License](https://img.shields.io/badge/License-MIT-green)

**Metaleon** is a high-performance [**Metal**](https://developer.apple.com/metal/)-based image and video processing library for iOS that offers real-time filtering and visual effects.

## Features

- **Image Filters**: Apply professional-grade filters including lookup tables, vignette, blending, bilateral filters and more
- **Visual Effects**: Add dynamic effects like glitch, RGB spark, VHS, old film, chromatic aberration and many others
- **Filter Chain**: Easily create complex filter combinations with JSON-formatted filter descriptions
- **Memory Optimization**: Efficiently manages GPU resources using MTLHeap
- **Real-time Processing**: Designed for high-performance real-time camera and video processing

## Supported Effects

### Image Filters
- Various customizable image filters with adjustable intensity

### Visual Effects
- Old Film
- VHS Camera/Tracking/Tape
- Chromatic VHS
- RGB Shift/Spark
- Glitch
- Trail
- Grid Effects
- Mirror Effects
- And many more

## Usage

```swift
// Initialize a filter provider
let filterProvider = ImageFiltersProvider()

// Apply filter to a Metal texture
let filteredTexture = filterProvider.currentFilterChain?.encode(
    to: commandBuffer, 
    sourceTexture: inputTexture
)

// Adjust filter intensity
filterProvider.updateParameters(with: 0.75)

// Switch between filters
filterProvider.next() // or .prev()
```

## Requirements

- iOS 14.0+
- Swift 5.7+
- Xcode 16.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Metaleon.git", from: "1.0.0")
]
```

## License

Metaleon is available under the MIT license. See the LICENSE file for more info.
