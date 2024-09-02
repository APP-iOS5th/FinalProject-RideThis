import Foundation

class RecordDetailViewModel {
    private let record: RecordModel
    
    init(record: RecordModel) {
        self.record = record
    }
    
    var title: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return record.record_start_time != nil ? dateFormatter.string(from: record.record_start_time!) : "Unknown Date"
    }
    
    var durationText: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let startTimeString = record.record_start_time != nil ? timeFormatter.string(from: record.record_start_time!) : "00:00"
        let endTimeString = record.record_end_time != nil ? timeFormatter.string(from: record.record_end_time!) : "23:59"
        return "\(startTimeString) ~ \(endTimeString)"
    }
    
    var timeText: String {
        return record.record_timer
    }
    
    var distanceText: String {
        return String(format: "%.2f km", record.record_distance)
    }
    
    var speedText: String {
        return String(format: "%.2f km/h", record.record_speed)
    }
    
    var calorieText: String {
        return String(format: "%.0f kcal", record.record_calories)
    }
}
