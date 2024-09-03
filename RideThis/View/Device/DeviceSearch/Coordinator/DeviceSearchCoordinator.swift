import UIKit

class DeviceSearchCoordinator: Coordinator {
    // MARK: - Properties
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    
    // MARK: - Initialization
    
    /// DeviceSearchCoordinator 초기화
    /// - Parameter navigationController: 네비게이션 컨트롤러
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    
    // MARK: - Coordinator Methods
    
    /// 코디네이터 시작: DeviceSearchView를 모달로 표시
    func start() {
        let deviceSearchVC = DeviceSearchView(viewModel: DeviceViewModel())
        deviceSearchVC.coordinator = self
        deviceSearchVC.modalPresentationStyle = .pageSheet
        
        if let sheet = deviceSearchVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(deviceSearchVC, animated: true)
    }
    
    /// 현재 뷰 닫기
    func dismissView() {
        navigationController.dismiss(animated: true)
    }
}
