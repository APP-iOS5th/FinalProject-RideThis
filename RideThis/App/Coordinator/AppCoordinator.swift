//
//  AppCoordinator.swift
//  RideThis
//
//  Created by SeongKook on 8/27/24.
//

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
    
    func changeTabBarView(change immedialtely: Bool = false) {
        let tabBarController = UITabBarController()
        let tabBarCoordinator = TabBarCoordinator(tabBarController: tabBarController)
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()

        // window의 rootViewController를 tabBarController로 변경
        if let window = window {
            if immedialtely {
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
            } else {            
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = tabBarController
                    window.makeKeyAndVisible()
                }, completion: nil)
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
