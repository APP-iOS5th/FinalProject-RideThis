////
////  CompetitionCoordinator.swift
////  RideThis
////
////  Created by SeongKook on 8/13/24.
////
//
//import UIKit
//
//class CompetitionCoordinator: Coordinator {
//    
//    var navigationController: UINavigationController
//    var childCoordinators: [Coordinator] = []
//    
//    init(navigationController: UINavigationController) {
//        self.navigationController = navigationController
//        
//    }
//    
//    func start() {
//        let competitionVC = CompetitionView()
//        competitionVC.coordinator = self
//    }
//    
////    func start() {
////        let competitionVC = CompetitionView()
////        competitionVC.coordinator = self
////        print("CompetitionCoordinator is set: \(competitionVC.coordinator)")
////        
////        navigationController.pushViewController(competitionVC, animated: true)
////    }
//    
//    func moveToDistanceSelectionView() {
//        print("View Mooooooove")
//        let distanceSelectionCoordinator = DistanceSelectionCoordinator(navigationController: navigationController)
//        distanceSelectionCoordinator.parentCoordinator = self
//        childCoordinators.append(distanceSelectionCoordinator)
//        
//        distanceSelectionCoordinator.start()
//    }
//}
