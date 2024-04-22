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

- iOS 13.0 or later
- Swift 5.0 or later
- Xcode 11.0 or later
- Swift Tools 5.10 or later

## Installation

### Swift Package Manager

The Swift Package Manager (SPM) is a tool for managing the distribution of Swift code. It automates the process of downloading, compiling, and linking dependencies.

To add SmartSpectra iOS SDK as a dependency to your Xcode project using SPM, follow these steps:

1. Open your project in Xcode.
2. Navigate to File > Swift Packages > Add Package Dependency...
3. Paste the repository URL in the search bar and press Enter. https://github.com/Presage-Security/SmartSpectra-iOS-SDK
4. Follow the prompts to choose the package options and add the package to your project.


## API Key

You'll need an API key to use the SmartSpectra iOS SDK. You can register for an account and obtain an API key at https://physiology.presagetech.com.

## Usage
### Example Code
Please refer to [ContentView.swift](Test SmartSpectra SDK/ContentView.swift) for example usage and plotting of a pulse pleth waveform and breathing waveform.
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
`SmartSpectraIosSDK.shared` has 3 observable objects:

-  `sdk.strictPulseRate` - (Double) the strict Pulse Rate
-  `sdk.strictBreathingRate` - (Double) the strict Breathing Rate
-  `sdk.jsonMetrics` - (Dictionary) containing the metrics available according to your api key. See Data Format below for the contents and structure.

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
The following are descirptions of the metrics:

hr: pulse rate (time, value, and confidence)

rr: breath rate (time, value, and confidence)

hr_trace: rppg (time, value)

rr_trace: breathing trace (time, value)

hr_spec: pulse rate spectrogram (time, value, freq)

rr_spec: breath rate spectrogram (time, value, freq)

hrv: pulse rate variability (RMSSD) (time, value)

phasic: an estimate of relative blood pressure (time, value)

rrl: respiratory line length (time, value)

apnea: boolean True if subject not breathing was detected

ie: exhalation/inhalation, sampled once for each breath cycle (time, value)

amplitude: amplitude of breathing waveform

baseline: baseline of breathing waveform


## Troubleshooting
For additional support, contact support@presagetech.com or submit a github issue (https://github.com/Presage-Security/SmartSpectra-iOS-App/issues)



## Known Bugs
- Will sometimes crash on initial launch after accepting camera permissions
- HRV is not returning 
- Back button on measurement view is not working 





