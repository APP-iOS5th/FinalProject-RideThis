////
////  DistanceSelectionCoordinator.swift
////  RideThis
////
////  Created by SeongKook on 8/13/24.
////
//
//import UIKit
//
//class DistanceSelectionCoordinator: Coordinator {
//    var navigationController: UINavigationController
//    weak var parentCoordinator: CompetitionCoordinator?
//    var childCoordinators: [Coordinator] = [] 
//    
//    init(navigationController: UINavigationController) {
//        self.navigationController = navigationController
//    }
//    
//    func start() {
//        print("View Starttttt")
//        let distanceSelectionVC = DistanceSelectionViewController()
//        distanceSelectionVC.coordinator = self
//        
//        self.navigationController.pushViewController(distanceSelectionVC, animated: true)
//    }
//}
