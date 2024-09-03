import Foundation
import Combine

class AlarmViewModel {
    
    private let firebaseService = FireBaseService()
    private let uesrService = UserService.shared
    @Published var alarams: [AlarmModel] = []
    
    func fetchAlarmDatas() {
        guard let signedUser = uesrService.signedUser else { return }
        Task {
            self.alarams = await firebaseService.fetchAlarms(userId: signedUser.user_id)
        }
    }
}
