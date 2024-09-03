import UIKit

class MyPageCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let myPageVC = MyPageView(viewModel: MyPageViewModel(firebaseService: FireBaseService(), periodCase: .oneWeek))
        myPageVC.coordinator = self

        navigationController.pushViewController(myPageVC, animated: true)
    }
}
