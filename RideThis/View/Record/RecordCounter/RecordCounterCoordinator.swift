import UIKit

class RecordCountCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let countViewController = RecordCounterViewController()
        countViewController.coordinator = self

        countViewController.modalPresentationStyle = .overFullScreen
        navigationController.present(countViewController, animated: true, completion: nil)
    }
    
    func countdownFinish() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}
