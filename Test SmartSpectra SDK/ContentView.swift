//  ContentView.swift
//  Test SmartSpectra SDK
import SwiftUI
import SmartSpectraIosSDK

struct ContentView: View {
    @ObservedObject var sdk = SmartSpectraIosSDK.shared
    var body: some View {
        VStack {
            // Add button to view and put in API Key
            SmartSpectraButtonView(apiKey: "YOUR_API_KEY_HERE")
            // Add Strict Breathing Rate and Pulse Rate View
            SmartSpectraSwiftUIView()
            // If you would like to do something with the Strict Breathing Rate and Pulse Rate Values
            // Text("Strict Pulse Rate Value: \(String(format: "%.2f", sdk.strictPulseRate))")
            // Text("Stric Breathing Rate Value: \(String(format: "%.2f", sdk.strictBreathingRate))")
            
            // Example of extracting, sorting and plotting the Pulse Pleth Waveform from sdk.
            if !SmartSpectraIosSDK.shared.pulsePleth.isEmpty {
                LineChartView(
                    orderedPairs: SmartSpectraIosSDK.shared.pulsePleth
                ).frame(height: 200)
            } else {
                // No Data avialable so display a flat line
                createFlatLine()
            }
            
            // Example of extracting, sorting and plotting the Pulse Pleth Waveform from sdk.
            // plot the data
            if !SmartSpectraIosSDK.shared.breathingPleth.isEmpty {
                LineChartView(
                    orderedPairs: SmartSpectraIosSDK.shared.breathingPleth
                ).frame(height: 200)
            } else {
                // No Data available so display a flat line
                createFlatLine()
            }
        }
        .padding()
    }
}
#Preview {
    ContentView()
}

// Below are some helper functions to extract and visualize data from SmartSpectra

/// `LineChartView` renders a line chart based on provided time and value data.
/// This View normalizes time and value data points to fit within the view's dimensions,
/// ensuring that the line chart accurately represents relative differences in data across its range.
struct LineChartView: View {
    let orderedPairs: [(time: Double, value: Double)]
    
    private var normalizedData: [(x: Double, y: Double)] {        
        guard let maxTime = orderedPairs.max(by: {$0.time < $1.time})?.time else { return [] }
        guard let maxValue = orderedPairs.max(by: {$0.value < $1.value}) else { return [] }
        guard let minValue = orderedPairs.min(by: {$0.value < $1.value}) else { return [] }
        let valueRange = maxValue.value - minValue.value // The range of your HR values

        return orderedPairs.map { orderedPair in
            let normalizedX = Double(orderedPair.time) / maxTime
            let normalizedY: Double
            if valueRange == 0 { // Check if valueRange is zero
                normalizedY = 0.5 // Center the line if all values are the same
            } else {
                normalizedY = (orderedPair.value - minValue.value) / valueRange // Normalize y-value to be within 0...1, adjusting for minValue and valueRange
            }
            return (x: normalizedX, y: normalizedY)
        }
    }
    
    var body: some View {
        Canvas { context, size in
            var path = Path()
            
            let data = normalizedData
            for (index, point) in data.enumerated() {
                let xPosition = point.x * size.width
                // Adjust yPosition calculation to utilize the entire height
                let yPosition = (1 - point.y) * size.height // Use the normalized y-value
                
                if index == 0 {
                    path.move(to: CGPoint(x: xPosition, y: yPosition))
                } else {
                    path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                }
            }
            
            context.stroke(path, with: .color(.red), lineWidth: 2)
        }
    }
}

func createFlatLine() -> some View {
    LineChartView(
        orderedPairs: (1...10).map { (0.0, Double($0)) }
    )
    .frame(height: 200) // Sets the height of the LineChartView
}
