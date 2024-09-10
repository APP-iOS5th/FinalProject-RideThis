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
    
    func changeTabBarView(change immediately: Bool = false, selectedCase: ViewCase = .home) {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.clipsToBounds = false
        let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: tabBarController.tabBar.frame.width, height: 0.5))
        separatorView.backgroundColor = .lightGray
        tabBarController.tabBar.addSubview(separatorView)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .primaryBackgroundColor 
        
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        let tabBarCoordinator = TabBarCoordinator(tabBarController: tabBarController, prevSelectedViewCase: selectedCase)
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
                    if let user = UserService.shared.combineUser {
                        Task {
                            await homeView.viewModel.fetchUserRecords(user: user)
                        }
                    }
                }
            } else {
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = tabBarController
                    window.makeKeyAndVisible()
                }, completion: { _ in
                    // HomeView의 데이터 로드 트리거
                    if let homeNav = tabBarController.viewControllers?.first as? UINavigationController,
                       let homeView = homeNav.viewControllers.first as? HomeView {
                        if let user = UserService.shared.combineUser {
                            Task {
                                await homeView.viewModel.fetchUserRecords(user: user)
                            }
                        }
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
