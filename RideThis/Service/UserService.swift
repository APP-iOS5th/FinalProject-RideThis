import Foundation
import AuthenticationServices
import Combine

enum UserStatus {
    case appleLogin
    case signedOut
}

class UserService {
    static let shared = UserService()
    
    @Published var userStatus: UserStatus = .signedOut
    let keyChain = Keychain()
    
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
                    self.getAppleUserProfile()
                case .revoked:
                    print("revoked")
//                    DispatchQueue.main.async {
//                        self.state = .signedOut
//                    }
                case .notFound:
                    print("notFound")
//                    DispatchQueue.main.async {
//                        self.state = .signedOut
//                    }
                default:
                    break
                }
            }
        }
    }
    
    func getAppleUserProfile() {
        
    }
    
    func appleSignIn(userId: String) {
        keyChain.save(key: "appleUserId", value: userId)
    }
}
