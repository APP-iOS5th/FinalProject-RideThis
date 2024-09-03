import Foundation

class SummaryRecordViewModel {
    let timer: String
    let cadence: Double
    let speed: Double
    let distance: Double
    let calorie: Double
    let startTime: Date
    let endTime: Date
    
    init(timer: String, cadence: Double, speed: Double, distance: Double, calorie: Double, startTime: Date, endTime: Date) {
        self.timer = timer
        self.cadence = cadence
        self.speed = speed
        self.distance = distance
        self.calorie = calorie
        self.startTime = startTime
        self.endTime = endTime
    }
}
