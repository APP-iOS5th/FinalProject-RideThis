import UIKit

class TabBarCoordinator: Coordinator {
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    
    var childCoordinators: [Coordinator] = []
    
    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
        self.navigationController = UINavigationController()
    }
    
    func start() {
        // Home
        let homeNavigationController = UINavigationController()
        let homeCoordinator = HomeCoordinator(navigationController: homeNavigationController, tabBarController: tabBarController)
        homeCoordinator.start()
        homeNavigationController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house.fill"), selectedImage: nil)
        childCoordinators.append(homeCoordinator)
        
        // Competetion
        let competetionNavigationController = UINavigationController()
        let competetionCoordinator = CompetitionCoordinator(navigationController: competetionNavigationController, tabBarController: tabBarController)
        competetionCoordinator.start()
        competetionNavigationController.tabBarItem = UITabBarItem(title: "경쟁", image: UIImage(systemName: "flag.checkered.2.crossed"), selectedImage: nil)
        childCoordinators.append(competetionCoordinator)
        
        // Record
        let recordNavigationController = UINavigationController()
        let recordCoordinator = RecordCoordinator(navigationController: recordNavigationController, tabBarController: tabBarController)
        recordCoordinator.start()
        recordNavigationController.tabBarItem = UITabBarItem(title: "기록", image: UIImage(systemName: "flag.checkered"), selectedImage: nil)
        childCoordinators.append(recordCoordinator)
        
        // Device
        let deviceNavigationController = UINavigationController()
        let deviceCoordinator = DeviceCoordinator(navigationController: deviceNavigationController)
        deviceCoordinator.start()
        deviceNavigationController.tabBarItem = UITabBarItem(title: "장치연결", image: UIImage(systemName: "externaldrive.connected.to.line.below.fill"), selectedImage: nil)
        childCoordinators.append(deviceCoordinator)
        
        // MyPage
        let myPageNavigationController = UINavigationController()
        let myPageCoordinator = MyPageCoordinator(navigationController: myPageNavigationController, tabBarController: tabBarController)
        myPageCoordinator.start()
        myPageNavigationController.tabBarItem = UITabBarItem(title: "마이페이지", image: UIImage(systemName: "person.circle.fill"), selectedImage: nil)
        childCoordinators.append(myPageCoordinator)
        
        // 탭바 뷰 컨트롤러 설정
        tabBarController.viewControllers = [homeNavigationController, competetionNavigationController, recordNavigationController, deviceNavigationController, myPageNavigationController]
        
        tabBarController.overrideUserInterfaceStyle = .light
        tabBarController.tabBar.tintColor = .primaryColor
    }
}
