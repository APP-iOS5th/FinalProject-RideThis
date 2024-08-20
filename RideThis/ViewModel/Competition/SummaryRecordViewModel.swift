//
//  SummaryRecordViewModel.swift
//  RideThis
//
//  Created by SeongKook on 8/17/24.
//

import Foundation

class SummaryRecordViewModel {
    let timer: String
    let cadence: Double
    let speed: Double
    let distance: Double
    let calorie: Double
    
    init(timer: String, cadence: Double, speed: Double, distance: Double, calorie: Double) {
        self.timer = timer
        self.cadence = cadence
        self.speed = speed
        self.distance = distance
        self.calorie = calorie
    }
}
