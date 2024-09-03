import UIKit

class WheelCircumferenceCoordinator: Coordinator {
    // MARK: - Properties
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    private let viewModel: DeviceViewModel
    
    
    // MARK: - Initialization
    
    /// WheelCircumferenceCoordinator 초기화
    /// - Parameters:
    ///   - navigationController: 네비게이션 컨트롤러
    ///   - viewModel: DeviceViewModel 인스턴스
    init(navigationController: UINavigationController, viewModel: DeviceViewModel) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    
    // MARK: - Coordinator Methods
    
    /// 코디네이터 시작: WheelCircumferenceView를 네비게이션 스택에 푸시
    func start() {
        let wheelCircumferenceVC = WheelCircumferenceView(viewModel: viewModel)
        wheelCircumferenceVC.coordinator = self
        navigationController.pushViewController(wheelCircumferenceVC, animated: true)
    }
    
    /// 현재 뷰에서 뒤로 가기
    func popView() {
        navigationController.popViewController(animated: true)
    }
}
