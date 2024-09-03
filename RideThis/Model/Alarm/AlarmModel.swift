import Foundation

class AlarmModel: Decodable {
    let alarm_body: String
    let alarm_category: String
    let alarm_date: Date
    let alarm_status: Bool
    
    init(alarm_body: String, alarm_category: String, alarm_date: Date, alarm_status: Bool) {
        self.alarm_body = alarm_body
        self.alarm_category = alarm_category
        self.alarm_date = alarm_date
        self.alarm_status = alarm_status
    }
}
