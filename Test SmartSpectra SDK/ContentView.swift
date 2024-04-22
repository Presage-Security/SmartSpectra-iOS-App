//
//  ContentView.swift
//  Test SmartSpectra SDK


import SwiftUI
import SmartSpectraIosSDK

struct ContentView: View {
    @ObservedObject var sdk = SmartSpectraIosSDK.shared
    private var randomSortedTimes: [Double] = (1...10).map { Double($0) }
    private var randomSortedHrValues: [Double] = (1...10).map { _ in Double.random(in: 60...100) }
    var body: some View {
        VStack {
            // Add button to view and put in API Key
            SmartSpectraButtonView(apiKey: "YOUR_API_KEY_HERE")
            // To get the results of Strict Breathing Rate and Pulse Rate user Display
            SmartSpectraSwiftUIView()
            // If you would like to do something with the Strict Breathing Rate and Pulse Rate Values
//            Text("Average Pulse Rate Value: \(String(format: "%.2f", sdk.strictPulseRate))")
//            Text("Average Breathing Rate Value: \(String(format: "%.2f", sdk.strictBreathingRate))")
            Spacer()
            
            // Example of extract the Pulse Pleth Waveform from sdk.jsonMetrics and plotting it
            if let json = sdk.jsonMetrics {
                let pulse = json["pulse"] as? [String: [String: Any]]
                if let hr = pulse?["hr_trace"] as? [String: [String: Any]] {
                    let timeHrPairs = hr.map { key, value -> (time: Double, hrValue: Double) in
                        if let time = Double(key), let hrValue = value["value"] as? Double {
                            return (time, hrValue)
                        } else {
                            return (0.0, 0.0) // Or handle invalid data appropriately
                        }
                    }.filter { $0.time != 0 } // Assuming you want to exclude invalid entries
                        .sorted { $0.time < $1.time }
                    
                    // Now, `timeHrPairs` is an array of tuples, sorted by time
                    // You can extract the times and HR values for plotting like so:
                    let sortedTimes = timeHrPairs.map { $0.time }
                    let sortedHrValues = timeHrPairs.map { $0.hrValue }
                    LineChartView(sortedTimes: sortedTimes, sortedHrValues: sortedHrValues)
                        .frame(height: 200)
                    // `sortedTimes` and `sortedHrValues` are now aligned and sorted for plotting
                }
            }else {
                // Display the chart with random data
                LineChartView(sortedTimes: randomSortedTimes, sortedHrValues: randomSortedHrValues)
                    .frame(height: 200)
            }
            Spacer()
            // Example of extract the Breathing Pleth Waveform from sdk.jsonMetrics and plotting it
            if let json = sdk.jsonMetrics {
                let breath = json["breath"] as? [String: [String: Any]]
                if let rr = breath?["rr_trace"] as? [String: [String: Any]] {
                    let timeRrPairs = rr.map { key, value -> (timerr: Double, rrValue: Double) in
                        if let timerr = Double(key), let rrValue = value["value"] as? Double {
                            return (timerr, rrValue)
                        } else {
                            return (0.0, 0.0) // Or handle invalid data appropriately
                        }
                    }.filter { $0.timerr != 0 } // Assuming you want to exclude invalid entries
                        .sorted { $0.timerr < $1.timerr }
                    
                    // Now, `timeHrPairs` is an array of tuples, sorted by time
                    // You can extract the times and HR values for plotting like so:
                    let sortedTimesrr = timeRrPairs.map { $0.timerr }
                    let sortedRrValues = timeRrPairs.map { $0.rrValue }
                    LineChartView(sortedTimes: sortedTimesrr, sortedHrValues: sortedRrValues)
                        .frame(height: 200)
                    // `sortedTimes` and `sortedHrValues` are now aligned and sorted for plotting
                }
            }else {
                // Display the chart with random data
                LineChartView(sortedTimes: randomSortedTimes, sortedHrValues: randomSortedHrValues)
                    .frame(height: 200)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}


// Function for plotting the waveforms
struct LineChartView: View {
    let sortedTimes: [Double]
    let sortedHrValues: [Double]
    
    private var normalizedData: [(x: Double, y: Double)] {
        let maxTime = sortedTimes.max() ?? 1
        let maxValue = sortedHrValues.max() ?? 1
        let minValue = sortedHrValues.min() ?? 0
        let valueRange = maxValue - minValue // The range of your HR values

        return zip(sortedTimes, sortedHrValues).map { time, value in
            let normalizedX = Double(time) / maxTime
            // Normalize y-value to be within 0...1, adjusting for minValue and valueRange
            let normalizedY = (value - minValue) / valueRange
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
            
            context.stroke(path, with: .color(.blue), lineWidth: 2)
        }
    }
}
