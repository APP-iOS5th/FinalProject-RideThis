import UIKit

class WheelCircumferenceCoordinator: Coordinator {
    // MARK: - Properties
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    private let viewModel: DeviceViewModel
    private let currentWheelCircumference: Int?
    
    // MARK: - Initialization
    
    /// WheelCircumferenceCoordinator 초기화
    /// 이 메서드는 휠의 둘레 값을 선택하는 화면을 관리하는 Coordinator를 초기화합니다.
    /// 선택한 휠의 둘레 값이 있을 경우, 해당 값을 사용해 초기 설정을 할 수 있습니다.
    ///
    /// - Parameters:
    ///   - navigationController: 화면 전환을 담당하는 UINavigationController 인스턴스
    ///   - viewModel: 휠과 관련된 데이터 로직을 관리하는 DeviceViewModel 인스턴스
    ///   - currentWheelCircumference: 선택된 휠의 둘레 값 (선택 사항, 기본값은 nil)
    init(navigationController: UINavigationController, viewModel: DeviceViewModel, currentWheelCircumference: Int? = nil) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.currentWheelCircumference = currentWheelCircumference
    }

    
    weak var delegate: WheelCircumferenceCoordinatorDelegate?
        
        func start() {
            let wheelCircumferenceVC = WheelCircumferenceView(viewModel: viewModel, currentWheelCircumference: currentWheelCircumference)
            wheelCircumferenceVC.coordinator = self
            wheelCircumferenceVC.onCircumferenceSelected = { [weak self] circumference, tireSize in
                self?.delegate?.wheelCircumferenceUpdated(circumference)
            }
            navigationController.pushViewController(wheelCircumferenceVC, animated: true)
        }
    

    protocol WheelCircumferenceCoordinatorDelegate: AnyObject {
        func wheelCircumferenceUpdated(_ circumference: Int)
    }
    
    
    // MARK: - Coordinator Methods
    
    /// 코디네이터 시작: WheelCircumferenceView를 네비게이션 스택에 푸시
//    func start() {
//        let wheelCircumferenceVC = WheelCircumferenceView(viewModel: viewModel, currentWheelCircumference: currentWheelCircumference)
//        wheelCircumferenceVC.coordinator = self
//        navigationController.pushViewController(wheelCircumferenceVC, animated: true)
//    }
    
    /// 현재 뷰에서 뒤로 가기
    func popView() {
        navigationController.popViewController(animated: true)
    }
}
