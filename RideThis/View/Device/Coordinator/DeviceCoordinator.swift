//
//  DeviceCoordinator.swift
//  RideThis
//
//  Created by SeongKook on 8/27/24.
//

import UIKit

class DeviceCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
    }
    
    func start() {
        let deviceVC = DeviceView()
        deviceVC.coordinator = self

        navigationController.pushViewController(deviceVC, animated: true)
    }
}
