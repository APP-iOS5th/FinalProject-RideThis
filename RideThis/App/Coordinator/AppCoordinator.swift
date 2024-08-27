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
    
    func changeTabBarView() {
        let tabBarController = UITabBarController()
        let tabBarCoordinator = TabBarCoordinator(tabBarController: tabBarController)
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()

        // window의 rootViewController를 tabBarController로 변경
        if let window = window {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
            }, completion: nil)
        }
    }
}
