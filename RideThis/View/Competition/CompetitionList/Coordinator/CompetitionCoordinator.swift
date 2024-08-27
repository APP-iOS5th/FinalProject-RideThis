//
//  CompetitionCoordinator.swift
//  RideThis
//
//  Created by SeongKook on 8/13/24.
//

import UIKit

class CompetitionCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
    }
    
    func start() {
        let competitionVC = CompetitionView()
        competitionVC.coordinator = self
        
        navigationController.pushViewController(competitionVC, animated: true)
    }

}
