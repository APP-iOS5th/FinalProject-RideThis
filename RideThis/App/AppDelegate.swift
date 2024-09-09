import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let userService = UserService.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase 초기화
        FirebaseApp.configure()
        
        let defaults = UserDefaults.standard
        let deleteStatus = defaults.data(forKey: "deleteStatus")
        
        if FirebaseApp.app() != nil {
            if deleteStatus != nil {
                userService.checkPrevAppleLogin()
            } else {
                userService.logout()
                do {
                    let statusData: [String: Any] = ["status": false]
                    let jsonData = try JSONSerialization.data(withJSONObject: statusData, options: [])
                    UserDefaults.standard.set(jsonData, forKey: "deleteStatus")
                } catch {
                    print("error > \(error)")
                }
            }
            print("Firebase Connect")
        } else {
            print("Firebase Failed Connect")
        }
        
        // 원격알림 등록: 푸시든 로컬이든 알람 허용해야 그 이후에 가능
        UNUserNotificationCenter.current().delegate = self
        
        // FirebaseMessaging
        Messaging.messaging().delegate = self
        
        // 로그인 상태 변화 감지
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(requestNotificationPermissionIfNeeded),
            name: Notification.Name("UserDidLogin"),
            object: nil
        )
        
        return true
    }
    
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    @objc func requestNotificationPermissionIfNeeded() {
        if userService.signedUser != nil {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { granted, error in
                    if let error = error {
                        print("알림 권한 요청 중 에러 발생: \(error)")
                        return
                    }
                    if granted {
                        print("알림 권한이 허용되었습니다.")
                        AlarmManager.shared.isUse = true
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    } else {
                        print("알림 권한이 거부되었습니다.")
                        AlarmManager.shared.isUse = false
                    }
                }
            )
        }
    }
}

// MARK: 푸시 알림 권한 요청
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    /// 푸시클릭시
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
    }
    
    /// 앱화면 보고있는중에 푸시올 때
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.sound, .banner, .list]
    }
    
    /// FCMToken 업데이트시
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        
        TokenManager.shared.fcmToken = fcmToken
    }
    
    /// 스위즐링 NO시, APNs등록, 토큰값가져옴
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        _ = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})

    }
    
    /// error발생시
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("🟢", error)
    }
}
