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
class User: Decodable {
    var user_id: String
    var user_image: String?
    let user_email: String
    var user_nickname: String
    var user_weight: Int
    var user_tall: Int
    var user_following: [String]
    var user_follower: [String]
    var user_account_public: Bool
//    let record_id: [String?]
//    let device_id: [String]
    var tallStr: String {
        get {
            guard user_tall > 0 else { return "-" }
            return "\(user_tall)"
        }
    }
    
    init(user_id: String, user_image: String?, user_email: String, user_nickname: String, user_weight: Int, user_tall: Int, user_following: [String], user_follower: [String], user_account_public: Bool/*, record_id: [String?], device_id: [String]*/) {
        self.user_id = user_id
        self.user_image = user_image
        self.user_email = user_email
        self.user_nickname = user_nickname
        self.user_weight = user_weight
        self.user_tall = user_tall
        self.user_following = user_following
        self.user_follower = user_follower
        self.user_account_public = user_account_public
//        self.record_id = record_id
//        self.device_id = device_id
    }
}
