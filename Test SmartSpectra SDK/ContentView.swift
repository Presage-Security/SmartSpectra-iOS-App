import SwiftUI
import AVFoundation
import SmartSpectraIosSDK

struct ContentView: View {
    @ObservedObject var sdk = SmartSpectraIosSDK.shared
    @State var cameraPosition: AVCaptureDevice.Position = .front
    @State var runningMode: SmartSpectraMode = .continuous
    @State var duration: Double = 30.0
    private var config: SmartSpectraConfiguration {
        if runningMode == .spot  {
            SpotModeConfiguration(duration: duration)
        } else {
            ContinuousModeConfiguration(maxDuration: duration)
        }
    }

    var body: some View {

        VStack {
            // Add the SmartSpectra SwiftUI View
            // (Required), set apiKey. API key from https://physiology.presagetech.com
            // (Optional), set spotDuration. Valid range for spot duration is between 20.0 and 120.0
            // (Optional), set showFPS. To show fps in the screening view
            // (Optional), set recordingDelay. To set a initial countdown timer before recording starts. Defaults to 3

            let apiKey = "YOUR_API_KEY_HERE"

            SmartSpectraView(apiKey: apiKey, configuration: config, showFps: false, recordingDelay: 3, cameraPosition: cameraPosition)
            // (Optional), example of how to switch camera at runtime
            Button(cameraPosition == .front ? "Switch to Back Camera": "Switch to Front Camera", systemImage: "camera.rotate") {
                if cameraPosition == .front {
                    cameraPosition = .back
                } else {
                    cameraPosition = .front
                }
                sdk.setCameraPosition(cameraPosition)
            }
            // (Optional), example of how to switch runningMode at runtime
            Button(runningMode == .spot ? "Switch to Continuous" : "Switch to Spot", systemImage: runningMode == .spot ? "waveform.path" : "chart.dots.scatter") {
                if runningMode == .spot {
                    runningMode = .continuous
                } else {
                    runningMode = .spot
                }
                sdk.setConfiguration(config)
            }

            // (Optional), example of how to change duration at runtime
            Stepper(value: $duration, in: 20...120, step: 5) {
                Text("Measurement Duration: \(duration.formatted(.number))")
            }
            .onChange(of: duration) {_ in
                sdk.setConfiguration(config)
            }


            // Scrolling view to view additional metrics from measurment
            ScrollView {
                VStack {
                 //  To show additional meta data of the analysis
                 //  Text("Metadata: \(String(describing: metricsBuffer.metadata))")

                    // Plotting example
                    if let metrics = sdk.metricsBuffer {
                        let pulse = metrics.pulse
                        let breathing = metrics.breathing
                        let bloodPressure = metrics.bloodPressure
                        let face = metrics.face

                        Section ("Pulse") {
                            if !pulse.trace.isEmpty {
                                LineChartView(orderedPairs: pulse.trace.map { ($0.time, $0.value) }, title: "Pulse Pleth", xLabel: "Time", yLabel: "Value", showYTicks: false)
                            }

                            if !pulse.rate.isEmpty {
                                LineChartView(orderedPairs: pulse.rate.map { ($0.time, $0.value) }, title: "Pulse Rates", xLabel: "Time", yLabel: "Value", showYTicks: true)
                                LineChartView(orderedPairs: pulse.rate.map { ($0.time, $0.confidence) }, title: "Pulse Rate Confidence", xLabel: "Time", yLabel: "Value", showYTicks: true)
                            }

//                            if !pulse..isEmpty {
//                                //for hrv analysis this will only be producable with 60 second version of SDK
//                                LineChartView(orderedPairs: pulse..map { ($0.time, $0.value) }, title: "Pulse Rate Variability", xLabel: "Time", yLabel: "value", showYTicks: true)
//                            }
                        }

                        Section ("Breathing") {
                            if !breathing.upperTrace.isEmpty {
                                LineChartView(orderedPairs: breathing.upperTrace.map { ($0.time, $0.value) }, title: "Breathing Pleth", xLabel: "Time", yLabel: "Value", showYTicks: false)
                            }

                            if !breathing.rate.isEmpty {
                                LineChartView(orderedPairs: breathing.rate.map { ($0.time, $0.value) }, title: "Breathing Rates", xLabel: "Time", yLabel: "Value", showYTicks: true)
                                LineChartView(orderedPairs: breathing.rate.map { ($0.time, $0.confidence) }, title: "Breathing Rate Confidence", xLabel: "Time", yLabel: "Value", showYTicks: true)
                            }

                            if !breathing.amplitude.isEmpty {
                                LineChartView(orderedPairs: breathing.amplitude.map { ($0.time, $0.value) }, title: "Breathing Amplitude", xLabel: "Time", yLabel: "Value", showYTicks: true)
                            }
                            if !breathing.apnea.isEmpty {
                                LineChartView(orderedPairs: breathing.apnea.map { ($0.time, $0.detected ? 1.0 : 0.0) }, title: "Apnea Detection", xLabel: "Time", yLabel: "Value", showYTicks: true)
                            }
                            if !breathing.baseline.isEmpty {
                                LineChartView(orderedPairs: breathing.baseline.map { ($0.time, $0.value) }, title: "Breathing Baseline", xLabel: "Time", yLabel: "Value", showYTicks: true)
                            }
                            if !breathing.respiratoryLineLength.isEmpty {
                                LineChartView(orderedPairs: breathing.respiratoryLineLength.map { ($0.time, $0.value) }, title: "Respiratory Line Length", xLabel: "Time", yLabel: "Value", showYTicks: true)
                            }

                            if !breathing.inhaleExhaleRatio.isEmpty {
                                LineChartView(orderedPairs: breathing.inhaleExhaleRatio.map { ($0.time, $0.value) }, title: "Inhale-Exhale Ratio", xLabel: "Time", yLabel: "Value", showYTicks: true)
                            }
                        }

                        Section ("Blood Pressure") {
                            if !bloodPressure.phasic.isEmpty {
                                LineChartView(orderedPairs: bloodPressure.phasic.map { ($0.time, $0.value) }, title: "Phasic", xLabel: "Time", yLabel: "Value", showYTicks: true)
                            }
                        }

                        Section ("Face") {
                            if !face.blinking.isEmpty {
                                LineChartView(orderedPairs: face.blinking.map { ($0.time, $0.detected ? 1.0 : 0.0) }, title: "Blinking", xLabel: "Time", yLabel: "Value", showYTicks: true)
                            }
                            if !face.talking.isEmpty {
                                LineChartView(orderedPairs: face.talking.map { ($0.time, $0.detected ? 1.0 : 0.0) }, title: "Talking", xLabel: "Time", yLabel: "Value", showYTicks: true)
                            }
                        }
                    }


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
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
