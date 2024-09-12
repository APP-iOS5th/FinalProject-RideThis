import Foundation
import Combine

class AlarmViewModel {
    
    private let firebaseService: FireBaseService
    private let uesrService = UserService.shared
    @Published var alarams: [AlarmModel] = []
    
    init(firebaseService: FireBaseService) {
        self.firebaseService = firebaseService
    }
    
    func fetchAlarmDatas() {
        guard let signedUser = uesrService.signedUser else { return }
        Task {
            self.alarams = await firebaseService.fetchAlarms(userId: signedUser.user_id)
            await readAllAlarms(user: signedUser)
        }
    }
    
    func updateAlarm(user: User, alarm: AlarmModel) {
        Task {
            await firebaseService.updateAlarm(user: user, alarm: alarm)
        }
    }
    
    func readAllAlarms(user: User) async {
        for alarm in self.alarams.filter({ $0.alarm_status == false }) {
            alarm.alarm_status = true
            await firebaseService.updateAlarm(user: user, alarm: alarm)
        }
    }
}
