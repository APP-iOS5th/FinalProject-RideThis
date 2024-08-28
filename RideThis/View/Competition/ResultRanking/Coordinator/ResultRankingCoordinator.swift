//
//  ResultRankingCoordinator.swift
//  RideThis
//
//  Created by SeongKook on 8/28/24.
//

import UIKit

class ResultRankingCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    var distance: Double
    
    init(navigationController: UINavigationController, distance: Double) {
        self.navigationController = navigationController
        self.distance = distance
    }
    
    func start() {
        let resultRankingVC = ResultRankingViewController(distance: distance)
        resultRankingVC.coordinator = self
        
        navigationController.pushViewController(resultRankingVC, animated: true)
    }
    
    func popToRootView() {
        self.navigationController.popToRootViewController(animated: true)
    }
    
    func moveToRetry() {
        let distanceCoordinator = DistanceSelectionCoordinator(navigationController: navigationController)
         childCoordinators.append(distanceCoordinator)
        
         distanceCoordinator.start()
    }
}
