import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var splashCoordinator: SplashCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)

        splashCoordinator = SplashCoordinator(window: self.window!)
        splashCoordinator?.start()
    }
    
    func getTabbarController(selectedIndex: Int = 0) -> UITabBarController {
        let homeView = UINavigationController(rootViewController: HomeView())
        homeView.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house.fill"), selectedImage: nil)
        
        let competitionView = UINavigationController(rootViewController: CompetitionView())
        competitionView.tabBarItem = UITabBarItem(title: "경쟁", image: UIImage(systemName: "flag.checkered.2.crossed"), selectedImage: nil)
        
        let recordView = UINavigationController(rootViewController: RecordView())
        recordView.tabBarItem = UITabBarItem(title: "기록", image: UIImage(systemName: "flag.checkered"), selectedImage: nil)
        
        let deviceView = UINavigationController(rootViewController: DeviceView())
        deviceView.tabBarItem = UITabBarItem(title: "장치연결", image: UIImage(systemName: "externaldrive.connected.to.line.below.fill"), selectedImage: nil)
        
        let myPageView = UINavigationController(rootViewController: MyPageView())
        myPageView.tabBarItem = UITabBarItem(title: "마이페이지", image: UIImage(systemName: "person.circle.fill"), selectedImage: nil)
        let tabbarController = UITabBarController()
        tabbarController.overrideUserInterfaceStyle = .light // 기본 라이트모드
        tabbarController.viewControllers = [homeView, competitionView, recordView, deviceView, myPageView]
//        tabbarController.viewControllers = [myPageView, competitionView, recordView, deviceView, homeView]
        tabbarController.tabBar.tintColor = .primaryColor
        tabbarController.selectedIndex = selectedIndex
        
        return tabbarController
    }
    
    func changeRootView(viewController: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        window.rootViewController = viewController
        UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil, completion: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
