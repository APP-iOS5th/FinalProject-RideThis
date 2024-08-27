//
//  MyPageCoordinator.swift
//  RideThis
//
//  Created by SeongKook on 8/27/24.
//

import UIKit

class MyPageCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
    }
    
    func start() {
        let myPageVC = MyPageView()
        myPageVC.coordinator = self

        navigationController.pushViewController(myPageVC, animated: true)
    }
}
