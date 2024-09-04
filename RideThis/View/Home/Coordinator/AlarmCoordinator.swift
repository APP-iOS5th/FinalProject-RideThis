import Foundation
import UIKit

class AlarmCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator]
    
    init(navigationController: UINavigationController, childCoordinators: [any Coordinator]) {
        self.navigationController = navigationController
        self.childCoordinators = childCoordinators
    }
    
    func start() {
        let alarmView = AlarmView()
        
        self.navigationController.pushViewController(alarmView, animated: true)
    }
}
