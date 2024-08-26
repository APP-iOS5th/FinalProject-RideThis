
import UIKit

class SplashCoordinator {
    private var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let splashViewController = SplashView()
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
        
        // 1.5초 후 메인 화면으로 전환
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showMainTabBar()
        }
    }
    
    private func showMainTabBar() {
        let tabBarController = UITabBarController()
        
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
        
        tabBarController.viewControllers = [homeView, competitionView, recordView, deviceView, myPageView]
        tabBarController.overrideUserInterfaceStyle = .light // 기본 라이트모드
        tabBarController.tabBar.tintColor = .primaryColor
        
        // 전환 애니메이션
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.window.rootViewController = tabBarController
        }, completion: nil)
    }
}
