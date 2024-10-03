# Swift Package Manager SmartSpectra SDK Integration Guide
This provides instructions for integrating and utilizing the Presage SmartSpectra SDK for Swift Package Manager (SPM) publicly hosted at [SmartSpectra-iOS SDK](https://github.com/Presage-Security/SmartSpectra-iOS-SDK) to measure physiology metrics from a 30 second measurement using the mobile device's camera.

The app contained in this repo is an example of using the SmartSpectra SDK and should run out of the box after adding [SmartSpectra-iOS SDK](https://github.com/Presage-Security/SmartSpectra-iOS-SDK) and adding an API key.

## Table of Contents
- [Requirements](#requirements)
- [Installation](#installation)
- [API Key](#api-key)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Known Bugs](#known-bugs)



## Requirements

- iOS 15.0 or later
- Xcode 15.0 or later
- Not usable with emulators or the Xcode simulator

## Installation

### Swift Package Manager

The Swift Package Manager (SPM) is a tool for managing the distribution of Swift code. It automates the process of downloading, compiling, and linking dependencies.

To add SmartSpectra iOS SDK as a dependency to your Xcode project using SPM, follow either of these two sets of steps within Xcode:

- Method 1:
Go to File -> "Add Package Dependencies..."
In the "Search or Enter Package URL" field, enter the URL "https://github.com/Presage-Security/SmartSpectra-iOS-SDK"
For the "Dependency Rule," select "Branch" and then "main."
For "Add to Target," select your project.

- Method 2: Open your project in Xcode.  Select your project in the Project Navigator, then click on the project in the Project/Targets Pane. Go to the Package Dependencies Tab, then click the "+" button 
   - **Note**: Some Version of Xcode Navigate to File > Swift Packages > Add Package Dependency
Paste the repository URL for SmartSpectra iOS SDK in the search bar and press Enter. URL is https://github.com/Presage-Security/SmartSpectra-iOS-SDK.
Select Add Package

## API Key

You'll need an API key to use the SmartSpectra iOS SDK. You can register for an account and obtain an API key at https://physiology.presagetech.com.
In this example usage repo look for the `SmartSpectraButtonView(apiKey: "YOUR_API_KEY_HERE")` line of [ContentView.swift](Test%20SmartSpectra%20SDK/ContentView.swift) for location to add your key.

## Usage
### Example Code
Please refer to [ContentView.swift](Test%20SmartSpectra%20SDK/ContentView.swift) for example usage and plotting of a pulse pleth waveform and breathing waveform.
- **Note**: to use this example repo make sure to under "Signing and Capabilities" of Targets "Test SmartSpectra" to set:
  - Team: Your desired developer profile
  - Bundle Identifier: Your desired bundle identifier such as: `com.johnsmith.smartspectratest`
  - If you are not a registered developer for the App Store follow the prompt to navigate to Settings > General > VPN & Device Management, then select your developer App certificate to trust it on your iOS device.

### Integrate the SmartSpectra View

You need to integrate the `SmartSpectraView` into your app which is composed of

- A button that allows the user to conduct a measurement and compute physiology metrics
- A resultview that shows the strict breathing rate and pulse rate after the measurement

Here's a simple example using SwiftUI:

```swift
import SwiftUI
import SmartSpectraIosSDK

struct ContentView: View {
    var body: some View {
        // (Required), set apiKey. API key from https://physiology.presagetech.com
        // (Optional), set spotDuration. Valid range for spot duration is between 20.0 and 120.0
        // (Optional), set showFPS. To show fps in the screening view
        SmartSpectraView(apiKey: "YOUR_API_KEY_HERE", spotDuration: 30.0, showFps: false)
   }
}
```

> [!IMPORTANT]
> You need to enter your API key string at `"YOUR_API_KEY_HERE"`. Optionally, you can also configure spot duration, whether to show frame per second (fps) during screening.

### Extracting and UsingMetrics Data


The `MetricsBuffer` is the main struct generated using [swift-protobuf](https://github.com/apple/swift-protobuf) that contains all metrics data. You can access it through a `@ObservedObject` instance of `SmartSpectraIosSDK.shared`. This way any update to the metrics data will automatically trigger a UI update.

**Usage Example:**

```swift
@ObservedObject var shared = SmartSpectraIosSDK.shared

if let metrics = sdk.metricsBuffer {
  // Use the metrics

  // Access pulse data
  metrics.pulse.rate.forEach { measurement in
      print("Pulse rate value: \(measurement.value), time: \(measurement.time), confidence: \(measurement.confidence)")
  }

  // Access breathing data
  metrics.breathing.rate.forEach { rate in
      print("Breathing rate: \(rate.value), time: \(rate.time), confidence: \(rate.confidence)")
  }
}


```

### Detailed `MetricsBuffer` Struct Descriptions

> [!TIP]
> If you need to use the types directly, the MetricsBuffer and corresponding structs are under the `Presage_Physiology` namespace. You can type alias it from the `Presage_Physiology_MetricsBuffer` to `MetricsBuffer` for easier usage:
> ```swift
> typealias MetricsBuffer = Presage_Physiology_MetricsBuffer
> ```

Metrics Buffer contains the following parent structs:

```swift
struct MetricsBuffer {
    var pulse: Pulse
    var breathing: Breathing
    var bloodPressure: BloodPressure
    var face: Face
    var metadata: Metadata
}
```

### Measurement Types

- **`Measurement` Struct** : Represents a measurement with time and value:

```swift
struct Measurement {
    var time: Float
    var value: Float
    var stable: Bool
}
```

- **`MeasurementWithConfidence` Struct** : Includes confidence with the measurement:

```swift
struct MeasurementWithConfidence {
    var time: Float
    var value: Float
    var stable: Bool
    var confidence: Float
}
```

- **`DetectionStatus` Struct** :Used for events like apnea or face detection (blinking/talking):

```swift
struct DetectionStatus {
    var time: Float
    var detected: Bool
    var stable: Bool
}
```

#### Metric Types

- **`Pulse` Struct** : Contains pulse-related measurements, including rate, trace, and strict values:

```swift
struct Pulse {
    var rate: [MeasurementWithConfidence]
    var trace: [Measurement]
    var strict: Strict
}
```

- **`Breathing` Struct** : Handles breathing-related data with upper and lower traces, amplitude, apnea status, and other metrics:

```swift
struct Breathing {
    var rate: [MeasurementWithConfidence]
    var upperTrace: [Measurement]
    var lowerTrace: [Measurement]
    var amplitude: [Measurement]
    var apnea: [DetectionStatus]
    var respiratoryLineLength: [Measurement]
    var inhaleExhaleRatio: [Measurement]
    var strict: Strict
}
```

- **`BloodPressure` Struct** : Handles blood pressure measurements:

> [!CAUTION]
> Currently not available publicly, currently returned results are a duplicate of pulse pleth

```swift
struct BloodPressure {
    var phasic: [MeasurementWithConfidence]
}
```

- **`Face` Struct** : Includes detection statuses for blinking and talking:

```swift
struct Face {
    var blinking: [DetectionStatus]
    var talking: [DetectionStatus]
}
```

- **`Metadata` Struct** : Includes metadata information:

```swift
struct Metadata {
    var id: String
    var uploadTimestamp: String
    var apiVersion: String
}
```

#### Encoding and Decoding Protobuf Messages

To serialize `MetricsBuffer` into binary format:

```swift
do {
    let data = try metrics.serializedData()
    // Send `data` to your backend or save it
} catch {
    print("Failed to serialize metrics: \(error)")
}
```

To decode binary protobufdata into `MetricsBuffer`:

```swift
do {
    let decodedMetrics = try MetricsBuffer(serializedBytes: data)
    // Use `decodedMetrics` as needed
} catch {
    print("Failed to decode metrics: \(error)")
}
```

### Displaying face mesh points

You can display the face mesh points by following the example in [ContentView.swift](Test%20SmartSpectra%20SDK/ContentView.swift)

```Swift
if !sdk.meshPoints.isEmpty {
   // Visual representation of mesh points
   GeometryReader { geometry in
         ZStack {
            ForEach(Array(sdk.meshPoints.enumerated()), id: \.offset) { index, point in
               Circle()
                     .fill(Color.blue)
                     .frame(width: 3, height: 3)
                     .position(x: CGFloat(point.x) * geometry.size.width / 1280.0,
                           y: CGFloat(point.y) * geometry.size.height / 1280.0)
            }
         }
   }
   .frame(width: 400, height: 400) // Adjust the height as needed
}
```

Since the mesh points are published you can also use `combine` to subscribe to the mesh points to add a custom callback to further process the mesh points.

## Device Orientation

We do not recommend landscape support. We recommend removing the "Landscape Left," "Landscape Right," and "Portrait Upside Down" modes from your supported interface orientations.

## Troubleshooting

For additional support, contact support@presagetech.com or submit a [Github Issue](https://github.com/Presage-Security/SmartSpectra-iOS-App/issues)

## Known Bugs

- Currently, there are no known bugs. If you encounter an issue, please contact support or report it.
