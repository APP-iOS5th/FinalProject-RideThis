import UIKit
import Combine

class RecordCoordinator: Coordinator {
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController, tabBarController: UITabBarController) {
        self.navigationController = navigationController
        self.tabBarController = tabBarController
    }
    
    func start() {
        let recordVC = RecordView(viewModel: RecordViewModel())
        recordVC.coordinator = self
        
        navigationController.pushViewController(recordVC, animated: true)
    }
    
    // MARK: - 뷰 이동
    func showSummaryView(viewModel: RecordViewModel) {
        let sumUpCoordinator = RecordSumUpCoordinator(navigationController: navigationController)
        childCoordinators.append(sumUpCoordinator)
        sumUpCoordinator.parentCoordinator = self
        
        let summaryData = viewModel.getSummaryData()
        let sumUpViewModel = RecordSumUpViewModel(summaryData: summaryData)
        sumUpCoordinator.start(with: sumUpViewModel)
    }
    
    func showRecordListView() {
        let listCoordinator = RecordListCoordinator(navigationController: navigationController)
        childCoordinators.append(listCoordinator)
        listCoordinator.parentCoordinator = self
        listCoordinator.start()
    }
    
    func showLoginView() {
        let loginVC = LoginView()
        self.navigationController.pushViewController(loginVC, animated: true)
    }
    
    func showDeviceConnectionView() {
        tabBarController.selectedIndex = 3
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
