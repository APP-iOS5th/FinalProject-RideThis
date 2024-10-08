import UIKit
import SnapKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseFirestore

class LoginView: RideThisViewController {
    
    // MARK: Data Components
    private let firebaseService = FireBaseService()
    let userService = UserService.shared
    let viewModel = LoginViewModel()
    var loginCoordinator: LoginCoordinator?
    var btnChangeDelegate: ChangeRecordButtonVisible?
    fileprivate var currentNonce: String?
    
    // MARK: UI Components
    private lazy var logoImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "logoTransparentWithName")
        image.contentMode = .scaleAspectFit
        let widthAndHeight = self.view.frame.width - 100
        image.widthAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        image.heightAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        
        return image
    }()
    private let chatLabel = RideThisLabel(fontType: .profileFont, text: "로그인해서 라이더의 체력을 향상시키세요.")
    private let loginButton = AppleLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "계정 설정"
        view.addSubview(logoImage)
        view.addSubview(chatLabel)
        view.addSubview(loginButton)
        
        logoImage.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        chatLabel.snp.makeConstraints {
            $0.top.equalTo(logoImage.snp.bottom).offset(20)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(chatLabel.snp.bottom).offset(20)
            $0.left.equalTo(view.snp.left).offset(15)
            $0.right.equalTo(view.snp.right).offset(-15)
        }
        
        loginButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.startSignInWithAppleFlow()
        }, for: .touchUpInside)
    }
}

extension LoginView: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let userId = appleIDCredential.user
            let userEmail = appleIDCredential.email
            
            let credential = OAuthProvider.credential(providerID: AuthProviderID.apple, idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error in SignIn \(error.localizedDescription) \(#function) \(#line)")
                    return
                }
                
                let service = FireBaseService()
                Task {
                    do {
                        if let scene = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate) {
                            // MARK: apple 로그인 정보 KeyChain에 저장
                            UserService.shared.appleSignIn(userId: userId)
                            if case .user(let userData) = try await service.fetchUser(at: userId, userType: true) {
                                if userData == nil {
                                    // MARK: 추가정보 입력 화면으로 이동
                                    let coordinator = SignUpCoordinator(navigationController: self.navigationController!,
                                                                        childCoordinators: self.loginCoordinator?.childCoordinators ?? [],
                                                                        userId: userId,
                                                                        userEmail: userEmail)
                                    coordinator.start()
                                } else {
                                    UserService.shared.signedUser = userData
                                    guard let coordinator = self.loginCoordinator else {
                                        NotificationCenter.default.post(name: Notification.Name("UserDidLogin"), object: nil)
                                        scene.appCoordinator?.changeTabBarView(change: true)
                                        return
                                    }
                                    if coordinator.prevViewCase == .summary {
                                        Task {
                                            self.btnChangeDelegate?.changeButton(afterLogin: true)
                                            await self.firebaseService.saveNoUserRecordData(user: userData!) {
                                                DataPersistenceService.shared.clearUnloginUserSummary()
                                            }
                                            coordinator.navigationController.popViewController(animated: true)
                                        }
                                    } else {
                                        scene.appCoordinator?.changeTabBarView(change: true, selectedCase: coordinator.prevViewCase)                                        
                                    }
                                    NotificationCenter.default.post(name: Notification.Name("UserDidLogin"), object: nil)
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

extension LoginView {
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
}

extension LoginView : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
