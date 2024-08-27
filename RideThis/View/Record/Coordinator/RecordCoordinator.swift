//
//  RecordCoordinator.swift
//  RideThis
//
//  Created by SeongKook on 8/27/24.
//

import UIKit

class RecordCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
    }
    
    func start() {
        let recordVC = RecordView()
        recordVC.coordinator = self

        navigationController.pushViewController(recordVC, animated: true)
    }
}
