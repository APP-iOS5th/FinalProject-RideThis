//
//  RecordSumUpCoordinator.swift
//  RideThis
//
//  Created by 황승혜 on 8/30/24.
//

import UIKit

class RecordSumUpCoordinator: Coordinator, RecordSumUpViewModelDelegate {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: RecordCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        fatalError("start() has not been implemented")
    }
    
    func start(with viewModel: RecordSumUpViewModel) {
        viewModel.delegate = self
        let sumUpVC = RecordSumUpView(viewModel: viewModel)
        sumUpVC.coordinator = self
        navigationController.pushViewController(sumUpVC, animated: true)
    }

    func didFinishSumUp() {
        parentCoordinator?.childDidFinish(self)
    }

    func didCancelSaveRecording() {
        navigationController.popViewController(animated: true)
        parentCoordinator?.childDidFinish(self)
    }

    func didSaveRecording() {
        navigationController.popViewController(animated: true)
        parentCoordinator?.childDidFinish(self)
    }
}
