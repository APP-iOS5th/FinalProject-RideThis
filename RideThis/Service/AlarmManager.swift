import UIKit
import UserNotifications

class AlarmManager {
    static let shared = AlarmManager()
    
    var isUse: Bool?
    
    private init() {}
    
    func openAppSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
    }
    
    func checkCurrentAlarmStatus(alarm status: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                status(false)
            case .denied:
                status(false)
            case .authorized, .provisional, .ephemeral:
                if settings.alertSetting == .enabled {
                    status(true)
                }
                if settings.badgeSetting == .enabled {
                    status(true)
                }
            @unknown default:
                status(false)
            }
        }
    }
}
