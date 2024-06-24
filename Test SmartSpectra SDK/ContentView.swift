import SwiftUI
import SmartSpectraIosSDK

struct ContentView: View {
    @ObservedObject var sdk = SmartSpectraIosSDK.shared
    var body: some View {
        VStack {
            // Add button to view and put in API Key
            SmartSpectraButtonView(apiKey: "YOUR_API_KEY_HERE")
                .frame(height: 125)
            // Add in the result view of the Strict Pulse and Breathing Rates
            SmartSpectraSwiftUIView()
            
            // Scrolling view to view additional metrics from measurment
            ScrollView {
                VStack {
                 //  To print additional meta data of the analysis
                 //  Text("Upload Date: \(sdk.uploadDate ?? "")")
                 //  Text("User ID: \(sdk.userID ?? "")")
                 //  Text("API Version: \(sdk.version ?? "")")
                    
                 //  for hrv analysis this will only be producable with 60 second version of SDK
                    if let hrvValue = sdk.hrv.first?.value {
                        Text("HRV (ms): \(hrvValue)")
                    }
                    LineChartView(orderedPairs: sdk.pulsePleth, title: "Pulse Pleth", xLabel: "Time", yLabel: "Value", showYTicks: false).frame(height: 200)
                    LineChartView(orderedPairs: sdk.breathingPleth, title: "Breathing Pleth", xLabel: "Time", yLabel: "Value", showYTicks: false).frame(height: 200)
                    LineChartView(orderedPairs: sdk.pulseValues, title: "Pulse Rates", xLabel: "Time", yLabel: "Value", showYTicks: true).frame(height: 200)
                    LineChartView(orderedPairs: sdk.pulseConfidence, title: "Pulse Rate Confidence", xLabel: "Time", yLabel: "Value", showYTicks: true).frame(height: 200)
                    LineChartView(orderedPairs: sdk.breathingValues, title: "Breathing Rates", xLabel: "Time", yLabel: "Value", showYTicks: true).frame(height: 200)
                    LineChartView(orderedPairs: sdk.breathingConfidence, title: "Breathing Rate Confidence", xLabel: "Time", yLabel: "Value", showYTicks: true).frame(height: 200)
                    LineChartView(orderedPairs: sdk.breathingAmplitude, title: "Breathing Amplitude", xLabel: "Time", yLabel: "Value", showYTicks: true).frame(height: 200)
                    LineChartView(orderedPairs: sdk.apnea, title: "Apnea", xLabel: "Time", yLabel: "Value", showYTicks: true).frame(height: 200)
                    LineChartView(orderedPairs: sdk.breathingBaseline, title: "Breathing Baseline", xLabel: "Time", yLabel: "Value", showYTicks: true).frame(height: 200)
                    LineChartView(orderedPairs: sdk.phasic, title: "Phasic", xLabel: "Time", yLabel: "Value", showYTicks: true).frame(height: 200)
                    LineChartView(orderedPairs: sdk.rrl, title: "RRL", xLabel: "Time", yLabel: "Value", showYTicks: true).frame(height: 200)
                    LineChartView(orderedPairs: sdk.ie, title: "IE", xLabel: "Time", yLabel: "Value", showYTicks: true).frame(height: 200)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

// Below are some helper functions to extract and visualize data from SmartSpectra

/// LineChartView renders a line chart based on provided time and value data.
/// This View displays time and value data points to fit within the view's dimensions.
struct LineChartView: View {
    let orderedPairs: [(time: Double, value: Double)]
    let title: String
    let xLabel: String
    let yLabel: String
    let showYTicks: Bool

    private let paddingFactor: Double = 0.05 // 5% padding on each side
    private let minimumRange: Double = 0.1 // Minimum range for y-axis

    private var minXValue: Double {
        orderedPairs.min(by: { $0.time < $1.time })?.time ?? 0
    }

    private var maxXValue: Double {
        orderedPairs.max(by: { $0.time < $1.time })?.time ?? 1
    }

    private var minYValue: Double {
        orderedPairs.min(by: { $0.value < $1.value })?.value ?? 0
    }

    private var maxYValue: Double {
        orderedPairs.max(by: { $0.value < $1.value })?.value ?? 1
    }

    private var minX: Double {
        return minXValue - paddingFactor * (maxXValue - minXValue)
    }

    private var maxX: Double {
        return maxXValue + paddingFactor * (maxXValue - minXValue)
    }

    private var adjustedMinY: Double {
        minYValue - paddingFactor * max(maxYValue - minYValue, minimumRange)
    }

    private var adjustedMaxY: Double {
        maxYValue + paddingFactor * max(maxYValue - minYValue, minimumRange)
    }

    private var xTickValues: [Double] {
        let strideSize = max(1.0, (maxX - minX) / 10) // Ensure X-axis ticks have a minimum stride size
        return Array(stride(from: ceil(minX), through: floor(maxX), by: strideSize))
    }

    private var yTickValues: [Double] {
        let numberOfTicks = 4
        let range = adjustedMaxY - adjustedMinY
        let strideSize = range / Double(numberOfTicks - 1)
        return range == 0 ? Array(repeating: adjustedMinY, count: numberOfTicks) : Array(stride(from: adjustedMinY, through: adjustedMaxY, by: strideSize))
    }

    var body: some View {
        VStack {
            Text(title).font(.headline)
            GeometryReader { geometry in
                VStack {
                    Canvas { context, size in
                        var path = Path()

                        for (index, point) in orderedPairs.enumerated() {
                            let xPosition = (point.time - minX) / (maxX - minX) * size.width
                            let yPosition = adjustedMaxY == adjustedMinY ? size.height / 2 : (1 - (point.value - adjustedMinY) / (adjustedMaxY - adjustedMinY)) * (size.height - 20) + 10

                            if index == 0 {
                                path.move(to: CGPoint(x: xPosition, y: yPosition))
                            } else {
                                path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                            }
                        }

                        context.stroke(path, with: .color(.red), lineWidth: 2)

                        // Draw X tick marks and labels inside the box plot, skip the first one
                        for (index, xTick) in xTickValues.enumerated() {
                            if index > 0 {
                                let xPosition = (xTick - minX) / (maxX - minX) * size.width
                                context.stroke(Path { path in
                                    path.move(to: CGPoint(x: xPosition, y: size.height))
                                    path.addLine(to: CGPoint(x: xPosition, y: size.height - 5))
                                }, with: .color(.black), lineWidth: 1)
                                context.draw(Text(String(format: "%.0f", xTick)).font(.caption), at: CGPoint(x: xPosition, y: size.height - 20), anchor: .top)
                            }
                        }

                        // Draw Y tick marks and labels inside the box plot
                        if showYTicks {
                            let yTicks = yTickValues
                            let range = adjustedMaxY - adjustedMinY
                            let strideSize = range / Double(yTicks.count - 1)
                            for yTick in yTicks {
                                let yPosition = adjustedMaxY == adjustedMinY ? size.height / 2 : (1 - (yTick - adjustedMinY) / (adjustedMaxY - adjustedMinY)) * (size.height - 20) + 10
                                context.stroke(Path { path in
                                    path.move(to: CGPoint(x: 0, y: yPosition))
                                    path.addLine(to: CGPoint(x: 5, y: yPosition))
                                }, with: .color(.black), lineWidth: 1)
                                let formatString = strideSize < 1 ? "%.2f" : "%.1f"
                                context.draw(Text(String(format: formatString, yTick)).font(.caption), at: CGPoint(x: 10, y: yPosition), anchor: .leading)
                            }
                        }
                    }
                    .border(Color.gray)

                    HStack {
                        Spacer()
                        Text(xLabel).font(.caption).padding([.top, .trailing])
                        Spacer()
                    }
                }
            }
        }
    }
}
