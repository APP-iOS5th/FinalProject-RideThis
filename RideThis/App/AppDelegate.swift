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
        
        if FirebaseApp.app() != nil {
            userService.checkPrevAppleLogin()
            print("Firebase Connect")
        } else {
            print("Firebase Failed Connect")
        }

        /*
         // 푸시 알림 권한 요청 설정
         UNUserNotificationCenter.current().delegate = self
         let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
         UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
         application.registerForRemoteNotifications()
         
         Messaging.messaging().delegate = self
         */
        // setupFCM(application)
        // 원격알림 등록: 푸시든 로컬이든 알람 허용해야 그 이후에 가능
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        // FirebaseMessaging
        Messaging.messaging().delegate = self

        return true
    }
    
    private func setupFCM(_ application: UIApplication) {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { isAgree, error in
            if isAgree {
                print("알림허용")
            }
        }
        application.registerForRemoteNotifications()
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
}

// MARK: 푸시 알림 권한 요청
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    /// 푸시클릭시
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("🟢", #function)
    }
    
    /// 앱화면 보고있는중에 푸시올 때
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        print("🟢", #function)
        return [.sound, .banner, .list]
    }
    
    /// FCMToken 업데이트시
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("🟢", #function, fcmToken ?? "")
//    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        let token = String(describing: fcmToken)
        print("Firebase registration token: \(token)")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
    
    /// 스위즐링 NO시, APNs등록, 토큰값가져옴
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("🟢", #function, deviceTokenString)
    }
    
    /// error발생시
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("🟢", error)
    }
}

/*
 extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {

     func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         Messaging.messaging().apnsToken = deviceToken
     }

     func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
         print("FCM Token: \(fcmToken ?? "")")
         // 여기서 fcmToken을 서버로 전송하여, 유저의 토큰을 저장합니다.
     }
 }
 */

