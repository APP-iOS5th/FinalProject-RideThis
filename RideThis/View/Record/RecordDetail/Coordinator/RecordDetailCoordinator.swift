import UIKit

class RecordDetailCoordinator: Coordinator {
    func start() {
        //
    }
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: RecordListCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start(with record: RecordModel) {
        let viewModel = RecordDetailViewModel(record: record)
        let detailVC = RecordDetailViewController()
        detailVC.coordinator = self
        detailVC.viewModel = viewModel
        navigationController.pushViewController(detailVC, animated: true)
    }

    func didFinishDetail() {
        parentCoordinator?.childDidFinish(self)
    }
}
