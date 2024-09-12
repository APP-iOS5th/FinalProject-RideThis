import UIKit

class CountCoordinator: Coordinator, CountViewControllerDelegate {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private var goalDistance: String
    
    init(navigationController: UINavigationController, goalDistance: String) {
        self.navigationController = navigationController
        self.goalDistance = goalDistance
    }
    
    func start() {
        let countViewController = CountViewController()
        countViewController.countDelegate = self
        countViewController.modalPresentationStyle = .overFullScreen
        navigationController.present(countViewController, animated: true, completion: nil)
    }
    
    // MARK: CountViewController Delegate
    func countdownFinish() {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let startCompetetionCoordinator = StartCompetetionCoordinator(navigationController: navigationController, goalDistance: goalDistance)
            childCoordinators.append(startCompetetionCoordinator)
            startCompetetionCoordinator.start()
        }
    }
}
