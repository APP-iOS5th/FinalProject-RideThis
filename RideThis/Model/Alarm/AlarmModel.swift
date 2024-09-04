import Foundation

class AlarmModel: Decodable {
    let alarm_body: String
    let alarm_category: String
    let alarm_date: Date
    var alarm_status: Bool
    let alarm_user: String
    
    init(alarm_body: String, alarm_category: String, alarm_date: Date, alarm_status: Bool, alarm_user: String) {
        self.alarm_body = alarm_body
        self.alarm_category = alarm_category
        self.alarm_date = alarm_date
        self.alarm_status = alarm_status
        self.alarm_user = alarm_user
    }
}
