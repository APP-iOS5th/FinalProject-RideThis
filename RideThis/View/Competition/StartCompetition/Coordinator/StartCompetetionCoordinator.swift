//
//  StartCompetetionCoordinator.swift
//  RideThis
//
//  Created by SeongKook on 8/27/24.
//

import UIKit

class StartCompetetionCoordinator: Coordinator, BluetoothViewDelegate {

    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private var bluetoothManager: BluetoothManager?
    
    private var goalDistance: String
    
    init(navigationController: UINavigationController, goalDistance: String) {
        self.navigationController = navigationController
        self.goalDistance = goalDistance
    }
    
    func start() {
        let startCompetetionVC = StartCompetitionViewController(goalDistance: goalDistance)
        startCompetetionVC.coordinator = self
        self.bluetoothManager = BluetoothManager(targetDeviceName: "DeviceName", userWeight: 70, wheelCircumference: 2.105)
        self.bluetoothManager?.viewDelegate = self
        self.navigationController.pushViewController(startCompetetionVC, animated: true)
    }
    
    func popToRootView() {
        self.navigationController.popToRootViewController(animated: true)
    }
    
    func moveToSummaryView(viewModel: StartCometitionViewModel) {
        let SummaryRecordCoordinator = SummaryRecordCoordinator(navigationController: navigationController, viewModel: viewModel)
        childCoordinators.append(SummaryRecordCoordinator)
        SummaryRecordCoordinator.start()
    }
    

    // MARK: BluetoothDelegate
    func bluetoothDidTurnOff() {
        guard let tabBarController = self.navigationController.tabBarController else {
            print("TabBarController not found")
            return
        }
        self.navigationController.popToRootViewController(animated: true)
        tabBarController.tabBar.items?.forEach{ $0.isEnabled = true }
        tabBarController.selectedIndex = 3
    }
}
