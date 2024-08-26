//
//  Double+Extension.swift
//  RideThis
//
//  Created by SeongKook on 8/16/24.
//

import Foundation

extension Double {
    func formattedWithThousandsSeparator() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    var getTwoDecimal: String {
        get {
            return String(format: "%.2f", self)
        }
    }
}

extension Int {
    var secondsToRecordTime: String {
        get {
            var hours = self / 3600
            var minutes = self / 60
            let seconds = self % 60
            if seconds > 30 {
                minutes += 1
            }
            if minutes >= 60 {
                hours += 1
            }
            
            if hours > 0 {
                return "\(hours)시간 \(minutes)분"
            } else if hours == 0 && minutes > 0 {
                return "\(minutes)분"
            } else if hours == 0 && minutes == 0 {
                return "1분"
            }
            return ""
        }
    }
}
