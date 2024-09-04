import UIKit

class DeviceCoordinator: Coordinator {
    // MARK: - Properties
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    let sharedViewModel = DeviceViewModel()
    
    
    // MARK: - Initialization
    
    /// DeviceCoordinator 초기화
    /// - Parameter navigationController: 네비게이션 컨트롤러
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    
    // MARK: - Coordinator Methods
    
    /// 코디네이터 시작: DeviceView를 네비게이션 스택에 푸시
    func start() {
        let deviceVC = DeviceView(viewModel: sharedViewModel)
        deviceVC.coordinator = self
        navigationController.pushViewController(deviceVC, animated: true)
    }
    
    /// 장치 검색 화면 표시
    func showDeviceSearchView() {
        let deviceSearchCoordinator = DeviceSearchCoordinator(navigationController: navigationController, viewModel: sharedViewModel)
        childCoordinators.append(deviceSearchCoordinator)
        deviceSearchCoordinator.start()
    }
    
    /// 특정 장치의 상세 정보 화면 표시
    /// - Parameters:
    ///   - deviceName: 장치 이름
    ///   - viewModel: DeviceViewModel 인스턴스
    func showDeviceDetailView(for deviceName: String, viewModel: DeviceViewModel) {
        let deviceDetailCoordinator = DeviceDetailCoordinator(navigationController: navigationController, deviceName: deviceName, viewModel: viewModel)
        childCoordinators.append(deviceDetailCoordinator)
        deviceDetailCoordinator.start()
    }
}
