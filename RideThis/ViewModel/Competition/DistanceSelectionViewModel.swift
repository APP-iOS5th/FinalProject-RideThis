//
//  DistanceSelectionViewModel.swift
//  RideThis
//
//  Created by SeongKook on 8/13/24.
//

import Foundation
import Combine

//enum startDistanceGame: String, CaseIterable {
//    case fiveKm = "5"
//    case tenKm = "10"
//    case thirtyKm = "30"
//    case hundredKm = "100"
//}

class DistanceSelectionViewModel {
    @Published var distance: String = ""
        


    // MARK: Choose Distnace
    func chooseDistance(distance: String) {
        self.distance = distance
    }
}
