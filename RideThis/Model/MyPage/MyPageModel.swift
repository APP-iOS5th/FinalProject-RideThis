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
