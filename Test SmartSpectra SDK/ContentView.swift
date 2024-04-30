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
            
            // Example of extracting, sorting and plotting the Pulse Pleth Waveform from sdk.jsonMetrics
            if let json = sdk.jsonMetrics {
                let pulse = json["pulse"] as? [String: [String: Any]]
                if let pulsePleth = pulse?["hr_trace"] as? [String: [String: Double]] {
                    // The data might not be in increasing time order so sort it on time
                    let sortedData = sortTimeValuePairs(from: pulsePleth)
                    // plot the data
                    LineChartView(times: sortedData.sortedTimes, values: sortedData.sortedValues).frame(height: 200)
                }
            }else {
                // No Data avialable so display a flat line
                createFlatLine()
            }
            
            // Example of extracting, sorting and plotting the Pulse Pleth Waveform from sdk.jsonMetrics
            if let json = sdk.jsonMetrics {
                let breath = json["breath"] as? [String: [String: Any]]
                if let breathingPleth = breath?["rr_trace"] as? [String: [String: Double]] {
                    // The data might not be in increasing time order so sort it on time
                    let sortedData = sortTimeValuePairs(from: breathingPleth)
                    // plot the data
                    LineChartView(times: sortedData.sortedTimes, values: sortedData.sortedValues).frame(height: 200)
                }
            }else {
                // No Data avialable so display a flat line
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

/// Sorts time and value pairs extracted from SmartSpectra sdk.jsonMetrics
///
/// The function takes a dictionary where keys represent time as strings and values
/// are dictionaries with a "value" key holding a Double. It extracts these pairs,
/// filters out any invalid entries where the time cannot be converted to Double or
/// the value is missing, sorts them by time, and then returns them in separate arrays.
///
/// - Parameter jsonMetric: A dictionary structured as [String: [String: Double]] where
///   the outer string key is the time and the inner dictionary contains a "value" key with a Double.
/// - Returns: A tuple containing two arrays: `sortedTimes` with all valid times as Double,
///   and `sortedValues` with corresponding Double values, both arrays are sorted by time.
func sortTimeValuePairs(from jsonMetric: [String: [String: Double]]) -> (sortedTimes: [Double], sortedValues: [Double]) {
    // Convert dictionary into array of tuples, filtering out invalid data
    let timeHrPairs = jsonMetric.compactMap { key, value -> (time: Double, value: Double)? in
        if let time = Double(key), let value = value["value"] {
            return (time, value)
        }
        return nil  // Skip invalid entries rather than substituting with (0.0, 0.0)
    }.sorted(by: { $0.time < $1.time })  // Sort by time

    // Extract sorted times and HR values
    let sortedTimes = timeHrPairs.map { $0.time }
    let sortedValues = timeHrPairs.map { $0.value }

    return (sortedTimes, sortedValues)
}

/// `LineChartView` renders a line chart based on provided time and value data.
/// This View normalizes time and value data points to fit within the view's dimensions,
/// ensuring that the line chart accurately represents relative differences in data across its range.
struct LineChartView: View {
    let times: [Double]
    let values: [Double]
    
    private var normalizedData: [(x: Double, y: Double)] {
        let maxTime = times.max() ?? 1
        let maxValue = values.max() ?? 1
        let minValue = values.min() ?? 0
        let valueRange = maxValue - minValue // The range of your HR values

        return zip(times, values).map { time, value in
            let normalizedX = Double(time) / maxTime
            let normalizedY: Double
            if valueRange == 0 { // Check if valueRange is zero
                normalizedY = 0.5 // Center the line if all values are the same
            } else {
                normalizedY = (value - minValue) / valueRange // Normalize y-value to be within 0...1, adjusting for minValue and valueRange
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
        times: (1...10).map { Double($0) }, // Generates an array of Double values from 1 to 10
        values: Array(repeating: 0.0, count: 10) // Generates an array with ten 0.0 values
    )
    .frame(height: 200) // Sets the height of the LineChartView
}
