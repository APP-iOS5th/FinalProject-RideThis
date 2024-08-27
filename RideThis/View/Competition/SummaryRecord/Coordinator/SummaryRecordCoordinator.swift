//
//  SummaryRecordCoordinator.swift
//  RideThis
//
//  Created by SeongKook on 8/28/24.
//

import UIKit

class SummaryRecordCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    var viewModel: StartCometitionViewModel
    
    init(navigationController: UINavigationController, viewModel: StartCometitionViewModel) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    func start() {
        let summaryRecordVC = SummaryRecordViewController(
            timer: viewModel.timer,
            cadence: viewModel.averageCadence,
            speed: viewModel.averageSpeed,
            distance: viewModel.goalDistance,
            calorie: viewModel.calorie,
            startTime: viewModel.startTime ?? Date(),
            endTime: viewModel.endTime ?? Date()
        )
        summaryRecordVC.coordinator = self
        
        navigationController.pushViewController(summaryRecordVC, animated: true)
    }
    
    func moveToResultView(distance: Double) {
        let resultRankingCoordinator = ResultRankingCoordinator(navigationController: navigationController, distance: distance)
        
        childCoordinators.append(resultRankingCoordinator)
        resultRankingCoordinator.start()
    }
}
