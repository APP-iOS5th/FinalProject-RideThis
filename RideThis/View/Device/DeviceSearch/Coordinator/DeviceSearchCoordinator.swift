import UIKit

class DeviceSearchCoordinator: Coordinator {
    // MARK: - Properties
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    let viewModel: DeviceViewModel
    
    
    // MARK: - Initialization
    
    /// DeviceSearchCoordinator 초기화
    /// - Parameters:
    ///   - navigationController: 네비게이션 컨트롤러
    ///   - viewModel: 공유할 DeviceViewModel 인스턴스
    init(navigationController: UINavigationController, viewModel: DeviceViewModel) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    
    // MARK: - Coordinator Methods
    
    /// 코디네이터 시작: DeviceSearchView를 모달로 표시
    func start() {
        let deviceSearchVC = DeviceSearchView(viewModel: viewModel)
        deviceSearchVC.coordinator = self
        deviceSearchVC.modalPresentationStyle = .pageSheet
        
        if let sheet = deviceSearchVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(deviceSearchVC, animated: true)
    }
    
    /// 현재 뷰 닫기
    func dismissViewAndRefreshDeviceView() {
        navigationController.dismiss(animated: true) { [weak self] in
            if let deviceView = self?.navigationController.viewControllers.last as? DeviceView {
                deviceView.refreshDeviceList()
            }
        }
    }
}
