import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var splashCoordinator: SplashCoordinator?

    func scene( scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)

        splashCoordinator = SplashCoordinator(window: self.window!)
        splashCoordinator?.start()
    }

    func sceneDidDisconnect( scene: UIScene) {}
    func sceneDidBecomeActive( scene: UIScene) {}
    func sceneWillResignActive( scene: UIScene) {}
    func sceneWillEnterForeground( scene: UIScene) {}
    func sceneDidEnterBackground( scene: UIScene) {}
}
