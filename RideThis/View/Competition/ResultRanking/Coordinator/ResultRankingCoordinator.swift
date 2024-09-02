import UIKit

class ResultRankingCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    var distance: Double
    
    init(navigationController: UINavigationController, distance: Double) {
        self.navigationController = navigationController
        self.distance = distance
    }
    
    func start() {
        let resultRankingVC = ResultRankingViewController(distance: distance)
        resultRankingVC.coordinator = self
        
        navigationController.pushViewController(resultRankingVC, animated: true)
    }
    
    func popToRootView() {
        self.navigationController.popToRootViewController(animated: true)
    }
    
    func moveToRetry() {
        // 네비게이션 스택에 뷰 컨트롤러가 있는지 확인
        let viewControllers = navigationController.viewControllers
        for controller in viewControllers {
            if controller is DistanceSelectionViewController {
                // DistanceSelectionViewController로 되돌아가기
                navigationController.popToViewController(controller, animated: true)
                return
            }
        }
        
        // 만약 DistanceSelectionViewController가 스택에 없다면, 새로운 Coordinator로 시작
        let distanceCoordinator = DistanceSelectionCoordinator(navigationController: navigationController)
        childCoordinators.append(distanceCoordinator)
        distanceCoordinator.start()
    }
}
