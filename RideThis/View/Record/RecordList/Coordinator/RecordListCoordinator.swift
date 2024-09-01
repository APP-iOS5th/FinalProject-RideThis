//
//  RecordListCoordinator.swift
//  RideThis
//
//  Created by 황승혜 on 8/30/24.
//

import UIKit

class RecordListCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: RecordCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let listVC = RecordListViewController()
        listVC.coordinator = self
        navigationController.pushViewController(listVC, animated: true)
    }

    func moveToRecordDetailView(with record: RecordModel) {
        let detailCoordinator = RecordDetailCoordinator(navigationController: navigationController)
        childCoordinators.append(detailCoordinator)
        detailCoordinator.parentCoordinator = self
        detailCoordinator.start(with: record)
    }

    func didFinishList() {
        parentCoordinator?.childDidFinish(self)
    }
    
    func childDidFinish(_ child: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if (child as AnyObject) === (coordinator as AnyObject) {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
