//
//  DistanceSelectionViewModel.swift
//  RideThis
//
//  Created by SeongKook on 8/13/24.
//

import Foundation
import Combine

class DistanceSlectionViewModel {
     let distanceSelection = ["5", "10", "30", "100"]
    
    @Published var distance: String
    
    init(distance: String) {
        self.distance = distance
    }
    
    func chooseDistonace(distance: String) {
        self.distance = distance
    }
}
