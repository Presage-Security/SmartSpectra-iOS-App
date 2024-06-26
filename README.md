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

**Note: Select feat/60_second_sdk for the branch if wanting 60 second measurements.**

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
### Integrating the SmartSpectra Button View and Adding API key

You need to integrate the `SmartSpectraButtonView` into your app which is a button that allows the user to conduct a measurement and compute physiology metrics. Here's a simple example using SwiftUI:

Note you need to ender your API key string at `"YOUR_API_KEY_HERE"`
```swift
import SwiftUI
import SmartSpectraIosSDK

struct ContentView: View {
    var body: some View {
        SmartSpectraButtonView(apiKey: "YOUR_API_KEY_HERE")
    }
}
```

### Displaying Strict Breathing Rate and Pulse Rate Values
You can display the strict breathing rate and pulse rate which is the average of only the high confidence breathing rate and pulse rate values over the 30 second measurement by adding the following to your view:
```Swift
SmartSpectraSwiftUIView()
```
### Extracting Metrics Data
To extract metrics data from the SDK import the following into your content view:
```Swift
@ObservedObject var sdk = SmartSpectraIosSDK.shared
```
`SmartSpectraIosSDK.shared` has 13 observable objects:

-  `sdk.strictPulseRate` - (Double) the strict pulse rate (high confidence average over 30 seconds)
-  `sdk.strictBreathingRate` - (Double) the strict breathing rate (high confidence average over 30 seconds)
-  `sdk.pulseValues` - [(time: Double, value: Double)] Pulse rates
- `sdk.pulseConfidence` - [(time: Double, value: Double)] Pulse rate confidences
- `sdk.pulsePleth` - [(time: Double, value: Double)] Pulse waveform or pleth
- `sdk.breathingValues` - [(time: Double, value: Double)] Breathing rates
- `sdk.breathingPleth` - [(time: Double, value: Double)] Breathing movement waveform or pleth
- `sdk.breathingAmplitude` - [(time: Double, value: Doube)] Breathing rate confidences
- `sdk.apnea` - [(time: Double, value: Double)] Apnea detection
- `sdk.breathingBaseline` - [(time: Double, value: Double)] Breathing baseline
- `sdk.phasic` - [(time: Double, value: Double)] Phasic (ie changes in relative blood pressure)
- `sdk.rrl` - [(time: Double, value: Double)] Respiratory line length
- `sdk.ie` - [(time: Double, value: Double)] The inhale exhale ratio
- `sdk.uploadDate` - (String) upload date time
- `sdk.version` - (String)  the version of API used
- `sdk.userID` - (String)  the user ID
-  `sdk.jsonMetrics` - (Dictionary) containing the metrics available according to your api key. See Data Format below for the contents and structure. **Warning: json structure is subject to change use at your own risk.**

### Data Format
`sdk.jsonMetrics` is structured as follows:
```json
{
  "error": "",
  "version": "3.10.1",
  "pulse": {
     "hr":{
         "10":{
              "value": 58.9,
              "confidence": 0.95,
         },
         "11":{
              "value": 58.2,
              "confidence": 0.94,
         },
         "12":{
              "value": 58.1,
              "confidence": 0.91,
         },
      },
     "hr_trace":{
         "0":{ "value": 0.5},
         "0.033":{ "value": 0.56},
         "0.066":{ "value": 0.59}
      },
     "hr_spec":{
         "10":{ "value": [], "freq":[]},
         "11":{ "value": [], "freq":[]},
         "12":{ "value": [], "freq":[]}
      },
     "hrv":{},
  },
  "breath": {
     "rr":{
         "15":{
              "value": 18.9,
              "confidence": 0.95,
         },
         "16":{
              "value": 18.2,
              "confidence": 0.94,
         },
         "17":{
              "value": 18.1,
              "confidence": 0.91,
         },
      },
     "rr_trace":{
         "0":{ "value": 0.5},
         "0.033":{ "value": 0.56},
         "0.066":{ "value": 0.59}
      },
     "rr_spec":{
         "15":{ "value": [], "freq":[]},
         "16":{ "value": [], "freq":[]},
         "17":{ "value": [], "freq":[]}
      },
     "rrl":{"0":{ "value": 0.5}},
     "apnea":{"0":{ "value": false}},
     "ie":{"0":{ "value": 1.5}},
     "amplitude":{"0":{ "value": 0.5}},
     "baseline":{"0":{ "value": 0.5}}
  },
  "pressure": {
     "phasic":{"0":{ "value": 0.5}},
  }
}
```


## Device Orientation
We do not recommend landscape support. We recommend removing the "Landscape Left," "Landscape Right," and "Portrait Upside Down" modes from your supported interface orientations.

## Troubleshooting
For additional support, contact support@presagetech.com or submit a github issue (https://github.com/Presage-Security/SmartSpectra-iOS-App/issues)



## Known Bugs
- HRV is not returning.

