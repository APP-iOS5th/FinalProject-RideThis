import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var window: UIWindow?
    
    init(navigationController: UINavigationController, window: UIWindow?) {
        self.navigationController = navigationController
        self.window = window
    }
    
    func start() {
        let splashVC = SplashView()
        splashVC.coordinator = self
        navigationController.pushViewController(splashVC, animated: true)
    }
    
    func changeTabBarView(change immediately: Bool = false) {
        let tabBarController = UITabBarController()
        let tabBarCoordinator = TabBarCoordinator(tabBarController: tabBarController)
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
        
        // window의 rootViewController를 tabBarController로 변경
        if let window = window {
            if immediately {
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
                
                // HomeView의 데이터 로드 트리거
                if let homeNav = tabBarController.viewControllers?.first as? UINavigationController,
                   let homeView = homeNav.viewControllers.first as? HomeView {
                    homeView.viewModel.fetchUserData()
                }
            } else {
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = tabBarController
                    window.makeKeyAndVisible()
                }, completion: { _ in
                    // HomeView의 데이터 로드 트리거
                    if let homeNav = tabBarController.viewControllers?.first as? UINavigationController,
                       let homeView = homeNav.viewControllers.first as? HomeView {
                        homeView.viewModel.fetchUserData()
                    }
                })
            }
        }
    }
    
    func changeRootView(viewController: UIViewController) {
        if let window = window {        
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }
}
