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
    
    func rounded(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
    
    var getTwoDecimal: Double {
        get {
            return Double(String(format: "%.2f", self))!
        }
    }
    
    var overThousandStr: String {
        get {
            let num = abs(self)
            let sign = (self < 0) ? "-" : ""
            
            switch num {
            case 1_000_000_000...:
                let formatted = num / 1_000_000_000
                return "\(sign)\(formatted.rounded(toPlaces: 1))B"
            case 1_000_000...:
                let formatted = num / 1_000_000
                return "\(sign)\(formatted.rounded(toPlaces: 1))M"
            case 1_000...:
                let formatted = num / 1_000
                return "\(sign)\(formatted.rounded(toPlaces: 1))K"
            case 0...:
                return "\(sign)\(self.getTwoDecimal)"
            default:
                return "\(sign)\(self.getTwoDecimal)"
            }
        }
    }
}

extension Int {
    var secondsToRecordTime: String {
        get {
            let hours = self / 3600
            let minutes = (self % 3600) / 60
            
            if hours > 0 {
//                return "\(hours)시간 \(minutes)분"
                return "\(hours)시간"
            } else if minutes > 0 {
                return "\(minutes)분"
            } else {
                return "0분"
            }
        }
    }
}
