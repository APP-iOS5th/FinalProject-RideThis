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
    
    func moveToEditView(user: User) {
        let editProfileCoordinator = EditProfileCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(editProfileCoordinator)
        
        editProfileCoordinator.start()
    }
    
    func showRecordListView() {
        let recordListCoordinator = RecordListCoordinator(navigationController: self.navigationController)
        recordListCoordinator.start()
    }
}
