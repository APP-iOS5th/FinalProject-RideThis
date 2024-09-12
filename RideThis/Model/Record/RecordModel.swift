import Foundation

// MARK: - Summary Data
struct SummaryData: Codable {
    let recordedTime: String
    let cadence: Double
    let speed: Double
    let distance: Double
    let calorie: Double
    let startTime: Date
    let endTime: Date
}
