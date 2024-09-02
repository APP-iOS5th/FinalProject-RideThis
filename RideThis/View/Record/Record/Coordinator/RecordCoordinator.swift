import UIKit

class RecordCoordinator: Coordinator {
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController, tabBarController: UITabBarController) {
        self.navigationController = navigationController
        self.tabBarController = tabBarController
    }

    func start() {
        let recordViewModel = RecordViewModel()
        recordViewModel.delegate = self

        let recordVC = RecordView()
        recordVC.coordinator = self
        recordVC.viewModel = recordViewModel

        navigationController.pushViewController(recordVC, animated: true)
    }

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

extension RecordCoordinator: RecordViewModelDelegate {
    func didResetRecording() {
        //
    }
    
    func didPauseRecording() {
        //
    }
    
    func didStartRecording() {
        //
    }
    
    func didFinishRecording() {
        // 현재 활성화된 RecordView의 viewModel을 가져옵니다.
        guard let recordView = navigationController.topViewController as? RecordView,
              let viewModel = recordView.viewModel else {
            print("Error: Unable to get the current RecordViewModel")
            return
        }
        
        // 요약 뷰로 이동합니다.
        showSummaryView(viewModel: viewModel)
    }
}
