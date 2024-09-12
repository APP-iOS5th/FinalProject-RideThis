import Foundation

extension Date {
    var convertedDate: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            
            return dateFormatter.string(from: self)
        }
    }
}
