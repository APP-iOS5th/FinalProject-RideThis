import Foundation

enum ShowingData: String, CaseIterable {
    case cadence = "Cadence"
    case distance = "Distance"
    case speed = "Speed"
    case calories = "Calories"
    
    var unit: String {
        get {
            switch self {
            case .cadence:
                return "RPM"
            case .distance:
                return "km"
            case .speed:
                return "km/h"
            case .calories:
                return "kcal"
            }
        }
    }
}
class User {
    let user_id: String = UUID().uuidString
    let user_image: String?
    let user_email: String
    let user_nickname: String
    let user_weight: Int
    let user_tall: Int?
    var user_following: [String]
    var user_follower: [String]
    let user_account_public: Bool = false
    let record_id: [String?]
    let device_id: [String]
    var tallStr: String {
        get {
            guard let tall = user_tall else { return "-" }
            return "\(tall)"
        }
    }
    
    init(user_image: String?, user_email: String, user_nickname: String, user_weight: Int, user_tall: Int?, user_following: [String], user_follower: [String], record_id: [String?], device_id: [String]) {
        self.user_image = user_image
        self.user_email = user_email
        self.user_nickname = user_nickname
        self.user_weight = user_weight
        self.user_tall = user_tall
        self.user_following = user_following
        self.user_follower = user_follower
        self.record_id = record_id
        self.device_id = device_id
    }
}
