//
//  DistanceSelectionCoordinator.swift
//  RideThis
//
//  Created by SeongKook on 8/13/24.
//

import UIKit

class DistanceSelectionCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let distanceSelectionVC = DistanceSelectionViewController()
        distanceSelectionVC.coordinator = self
        
        self.navigationController.pushViewController(distanceSelectionVC, animated: true)
    }
    
    func moveToCountView(with goalDistance: String) {
        let countCoordinator = CountCoordinator(navigationController: navigationController, goalDistance: goalDistance)
        childCoordinators.append(countCoordinator)
        countCoordinator.start()
    }
}

