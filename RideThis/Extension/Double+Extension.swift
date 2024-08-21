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
}
