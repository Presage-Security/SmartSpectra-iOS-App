import SwiftUI
import SmartSpectraIosSDK

struct ContentView: View {
    @ObservedObject var sdk = SmartSpectraIosSDK.shared
    var body: some View {
        
        VStack {
            // Add button to view and put in API Key
            SmartSpectraButtonView(apiKey: "YOUR_API_KEY_HERE")
                .task {
                    // Configure sdk parameters
                    // valid range for spot duration is between 20.0 and 120.0
                    sdk.setSpotDuration(30.0)
                    sdk.setShowFps(false)
                }
            // Add in the result view of the Strict Pulse and Breathing Rates
            SmartSpectraSwiftUIView()
            
            // Scrolling view to view additional metrics from measurment
            ScrollView {
                VStack {
                 //  To print additional meta data of the analysis
                 //  Text("Upload Date: \(sdk.uploadDate ?? "")")
                 //  Text("User ID: \(sdk.userID ?? "")")
                 //  Text("API Version: \(sdk.version ?? "")")
                    
                    if !sdk.pulsePleth.isEmpty {
                        LineChartView(orderedPairs: sdk.pulsePleth, title: "Pulse Pleth", xLabel: "Time", yLabel: "Value", showYTicks: false)
                    }
                    if !sdk.breathingPleth.isEmpty {
                        LineChartView(orderedPairs: sdk.breathingPleth, title: "Breathing Pleth", xLabel: "Time", yLabel: "Value", showYTicks: false)
                    }
                    if !sdk.pulseValues.isEmpty {
                        LineChartView(orderedPairs: sdk.pulseValues, title: "Pulse Rates", xLabel: "Time", yLabel: "Value", showYTicks: true)
                    }
                    if !sdk.pulseConfidence.isEmpty {
                        LineChartView(orderedPairs: sdk.pulseConfidence, title: "Pulse Rate Confidence", xLabel: "Time", yLabel: "Value", showYTicks: true)
                    }
                    if !sdk.hrv.isEmpty {
                        //for hrv analysis this will only be producable with 60 second version of SDK
                        LineChartView(orderedPairs: sdk.hrv, title: "Pulse Rate Variability", xLabel: "Time", yLabel: "value", showYTicks: true)
                    }
                    if !sdk.breathingValues.isEmpty {
                        LineChartView(orderedPairs: sdk.breathingValues, title: "Breathing Rates", xLabel: "Time", yLabel: "Value", showYTicks: true)
                    }
                    if !sdk.breathingConfidence.isEmpty {
                        LineChartView(orderedPairs: sdk.breathingConfidence, title: "Breathing Rate Confidence", xLabel: "Time", yLabel: "Value", showYTicks: true)
                    }
                    if !sdk.breathingAmplitude.isEmpty {
                        LineChartView(orderedPairs: sdk.breathingAmplitude, title: "Breathing Amplitude", xLabel: "Time", yLabel: "Value", showYTicks: true)
                    }
                    if !sdk.apnea.isEmpty {
                        LineChartView(orderedPairs: sdk.apnea.map { ($0.time, $0.value ? 1.0 : 0.0) }, title: "Apnea", xLabel: "Time", yLabel: "Value", showYTicks: true)
                    }
                    if !sdk.breathingBaseline.isEmpty {
                        LineChartView(orderedPairs: sdk.breathingBaseline, title: "Breathing Baseline", xLabel: "Time", yLabel: "Value", showYTicks: true)
                    }
                    if !sdk.phasic.isEmpty {
                        LineChartView(orderedPairs: sdk.phasic, title: "Phasic", xLabel: "Time", yLabel: "Value", showYTicks: true)
                    }
                    if !sdk.rrl.isEmpty {
                        LineChartView(orderedPairs: sdk.rrl, title: "RRL", xLabel: "Time", yLabel: "Value", showYTicks: true)
                    }
                    if !sdk.ie.isEmpty {
                        LineChartView(orderedPairs: sdk.ie, title: "IE", xLabel: "Time", yLabel: "Value", showYTicks: true)
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
