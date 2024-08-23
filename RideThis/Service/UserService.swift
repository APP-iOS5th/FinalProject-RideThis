import Foundation
import AuthenticationServices
import FirebaseFirestore
import Combine

enum UserStatus {
    case appleLogin
    case signedOut
}

class UserService {
    static let shared = UserService()
    private let keyChain = Keychain()
    var signedUser: User? = nil
    
    func checkPrevAppleLogin() {
        
        guard let userId = self.keyChain.read(key: "appleUserId") else {
            print("No valid user ID")
            return
        }
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userId) { (credentialState, error) in
            // state 변경 메인 스레드에서
            DispatchQueue.main.async {
                switch credentialState {
                case .authorized:
                    print("authorized")
                    Task {
                        await self.getUserInfo()
                    }
                case .revoked:
                    print("revoked")
                case .notFound:
                    print("notFound")
                default:
                    break
                }
            }
        }
    }
    
    func getUserInfo() async {
        let service = FireBaseService()
        do {
            guard let userId = self.keyChain.read(key: "appleUserId") else {
                print("No valid user ID")
                return
            }
            guard let user = try await service.fetchUser(at: userId) else {
                print("no user")
                return
            }
            let userData = try user.data(as: User.self)
            self.signedUser = userData
        } catch {
            print(error)
        }
    }
    
    func logout() {
        keyChain.delete(key: "appleUserId")
        self.signedUser = nil
        if let scene = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate) {
            scene.changeRootView(viewController: scene.getTabbarController(), animated: true)
        }
    }
    
    func appleSignIn(userId: String) {
        keyChain.save(key: "appleUserId", value: userId)
    }
}
