import UIKit

class DeviceDetailCoordinator: Coordinator, WheelCircumferenceCoordinator.WheelCircumferenceCoordinatorDelegate {
    // MARK: - Properties
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    private let deviceName: String
    private let viewModel: DeviceViewModel
    
    
    // MARK: - Initialization
    
    /// DeviceDetailCoordinator 초기화
    /// - Parameters:
    ///   - navigationController: 네비게이션 컨트롤러
    ///   - deviceName: 장치 이름
    ///   - viewModel: DeviceViewModel 인스턴스
    init(navigationController: UINavigationController, deviceName: String, viewModel: DeviceViewModel) {
        self.navigationController = navigationController
        self.deviceName = deviceName
        self.viewModel = viewModel
    }
    
    
    // MARK: - Coordinator Methods
    
    /// 코디네이터 시작: DeviceDetailView를 네비게이션 스택에 푸시
    func start() {
        let deviceDetailVC = DeviceDetailView(viewModel: viewModel, deviceName: deviceName)
        deviceDetailVC.coordinator = self
        navigationController.pushViewController(deviceDetailVC, animated: true)
    }
    
    /// 휠 둘레 설정 화면 표시
    func showWheelCircumferenceView() {
        let wheelCircumferenceCoordinator = WheelCircumferenceCoordinator(navigationController: navigationController, viewModel: viewModel)
        childCoordinators.append(wheelCircumferenceCoordinator)
        wheelCircumferenceCoordinator.start()
    }
    
    /// 루트 뷰로 돌아가기
    func popToRootView() {
        navigationController.popToRootViewController(animated: true)
    }
    
    /// 휠 둘레 설정 화면 표시
    func showWheelCircumferenceView(currentWheelCircumference: Int? = nil) {
        let wheelCircumferenceCoordinator = WheelCircumferenceCoordinator(navigationController: navigationController, viewModel: viewModel, currentWheelCircumference: currentWheelCircumference)
        wheelCircumferenceCoordinator.delegate = self
        childCoordinators.append(wheelCircumferenceCoordinator)
        wheelCircumferenceCoordinator.start()
    }
    
    // MARK: - WheelCircumferenceCoordinatorDelegate Methods
    
    func wheelCircumferenceUpdated(_ circumference: Int) {
        if let deviceDetailVC = navigationController.viewControllers.last as? DeviceDetailView {
            deviceDetailVC.updateWheelCircumference(circumference)
        }
    }
}
