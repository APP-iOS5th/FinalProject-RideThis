import UIKit

class MyPageCoordinator: Coordinator {
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController, tabBarController: UITabBarController) {
        self.navigationController = navigationController
        self.tabBarController = tabBarController
    }
    
    func start() {
        let myPageVC = MyPageView(viewModel: MyPageViewModel(firebaseService: FireBaseService(), periodCase: .oneWeek))
        myPageVC.coordinator = self

        navigationController.pushViewController(myPageVC, animated: true)
    }
    
    func showRecordListView() {
        let recordListCoordinator = RecordListCoordinator(navigationController: self.navigationController)
        recordListCoordinator.start()
//        if let recordNav = tabBarController.viewControllers?[2] as? UINavigationController {
//            tabBarController.selectedIndex = 2
//            if recordNav.topViewController is RecordListView {
//                return
//            }
//
//            let recordCoordinator = RecordCoordinator(navigationController: recordNav, tabBarController: tabBarController)
//            childCoordinators.append(recordCoordinator)
//            recordCoordinator.showRecordListView()
//        }
    }
}
