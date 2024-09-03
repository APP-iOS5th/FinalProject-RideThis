import UIKit
import Combine

class RecordCoordinator: Coordinator, BluetoothViewDelegate, BluetoothManagerDelegate {
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    var childCoordinators: [Coordinator] = []
    
    private var bluetoothManager: BluetoothManager?
    private var recordViewModel: RecordViewModel?
    
    private let bluetoothConnectionSubject = CurrentValueSubject<Bool, Never>(false)
    var bluetoothConnectionPublisher: AnyPublisher<Bool, Never> {
        bluetoothConnectionSubject.eraseToAnyPublisher()
    }
    
    private var lastDataUpdateTime: Date?
    private let connectionTimeout: TimeInterval = 10 // 10초 동안 데이터 업데이트가 없으면 연결 끊김으로 간주
    
    init(navigationController: UINavigationController, tabBarController: UITabBarController) {
        self.navigationController = navigationController
        self.tabBarController = tabBarController
    }
    
    func start() {
        recordViewModel = RecordViewModel()
        recordViewModel?.delegate = self
        
        let recordVC = RecordView()
        recordVC.coordinator = self
        recordVC.viewModel = recordViewModel
        
        initializeBluetoothManager()
        
        navigationController.pushViewController(recordVC, animated: true)
    }
    
    // 블루투스
    private func initializeBluetoothManager() {
        // BluetoothManager 초기화 로직
        Task {
            do {
                let deviceInfo = try await fetchDeviceData()
                DispatchQueue.main.async {
                    self.bluetoothManager = BluetoothManager(
                        targetDeviceName: deviceInfo.device_name,
                        userWeight: Double(UserService.shared.combineUser?.user_weight ?? -1),
                        wheelCircumference: deviceInfo.device_wheel_circumference
                    )
                    self.bluetoothManager?.delegate = self
                    self.bluetoothManager?.viewDelegate = self
                    self.bluetoothManager?.connect()
                }
            } catch {
                print("FIREBASE 통신 오류: \(error.localizedDescription)")
            }
        }
    }
    
    // 블루투스 연결 상태 확인 메서드
    func checkBluetoothConnection(completion: @escaping (Bool) -> Void) {
        if let isConnected = bluetoothManager?.isConnected() {
            completion(isConnected)
        } else {
            completion(false)
        }
    }
    
    func didUpdateCadence(_ cadence: Double) {
        lastDataUpdateTime = Date()
        recordViewModel?.didUpdateCadence(cadence)
    }
    
    func didUpdateSpeed(_ speed: Double) {
        lastDataUpdateTime = Date()
        recordViewModel?.didUpdateSpeed(speed)
    }
    
    func didUpdateDistance(_ distance: Double) {
        lastDataUpdateTime = Date()
        recordViewModel?.didUpdateDistance(distance)
    }
    
    func didUpdateCalories(_ calories: Double) {
        lastDataUpdateTime = Date()
        recordViewModel?.didUpdateCalories(calories)
    }
    
    private func fetchDeviceData() async throws -> RecordDeviceModel {
        let firebaseService = FireBaseService()
        let userDocument = try await firebaseService.fetchUser(at: UserService.shared.combineUser?.user_id ?? "", userType: false)
        
        if case .userSnapshot(let queryDocumentSnapshot) = userDocument {
            guard let doc = queryDocumentSnapshot else {
                throw NSError(domain: "RecordCoordinator", code: 1, userInfo: [NSLocalizedDescriptionKey: "User가 존재하지 않습니다."])
            }
            let recordsCollection = firebaseService.fetchCollection(document: doc, collectionName: "DEVICES")
            let deviceDocuments = try await recordsCollection.getDocuments()
            
            if let activeDeviceDocument = deviceDocuments.documents.first(where: { document in
                return document["device_registration_status"] as? Bool == true
            }) {
                return RecordDeviceModel(
                    device_firmware_version: activeDeviceDocument["device_firmware_version"] as? String ?? "",
                    device_name: activeDeviceDocument["device_name"] as? String ?? "",
                    device_registration_status: activeDeviceDocument["device_registration_status"] as? Bool ?? false,
                    device_serial_number: activeDeviceDocument["device_serial_number"] as? String ?? "",
                    device_wheel_circumference: activeDeviceDocument["device_wheel_circumference"] as? Double ?? 0
                )
            } else {
                throw NSError(domain: "RecordCoordinator", code: 2, userInfo: [NSLocalizedDescriptionKey: "등록된 DEVICES가 없습니다."])
            }
        } else {
            throw NSError(domain: "RecordCoordinator", code: 3, userInfo: [NSLocalizedDescriptionKey: "FIREBASE 통신 오류"])
        }
    }
    
    func bluetoothDidTurnOff() {
        guard let tabBarController = self.navigationController.tabBarController else {
            print("TabBarController not found")
            return
        }
        self.navigationController.popToRootViewController(animated: true)
        tabBarController.tabBar.items?.forEach{ $0.isEnabled = true }
        tabBarController.selectedIndex = 3    }
    
    func showSummaryView(viewModel: RecordViewModel) {
        let sumUpCoordinator = RecordSumUpCoordinator(navigationController: navigationController)
        childCoordinators.append(sumUpCoordinator)
        sumUpCoordinator.parentCoordinator = self
        
        let summaryData = viewModel.getSummaryData()
        let sumUpViewModel = RecordSumUpViewModel(summaryData: summaryData)
        sumUpCoordinator.start(with: sumUpViewModel)
    }
    
    func showRecordListView() {
        let listCoordinator = RecordListCoordinator(navigationController: navigationController)
        childCoordinators.append(listCoordinator)
        listCoordinator.parentCoordinator = self
        listCoordinator.start()
    }
    
    func showLoginView() {
        let loginVC = LoginView()
        self.navigationController.pushViewController(loginVC, animated: true)
    }
    
    func showDeviceConnectionView() {
        tabBarController.selectedIndex = 3
    }
    
    func childDidFinish(_ child: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if (child as AnyObject) === (coordinator as AnyObject) {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}

extension RecordCoordinator: RecordViewModelDelegate {
    func didResetRecording() {
    }
    
    func didPauseRecording() {
    }
    
    func didStartRecording() {
    }
    
    func didFinishRecording() {
        // 현재 활성화된 RecordView의 viewModel을 가져옵니다.
        guard let recordView = navigationController.topViewController as? RecordView,
              let viewModel = recordView.viewModel else {
            print("Error: Unable to get the current RecordViewModel")
            return
        }
        
        // 요약 뷰로 이동합니다.
        showSummaryView(viewModel: viewModel)
    }
}
