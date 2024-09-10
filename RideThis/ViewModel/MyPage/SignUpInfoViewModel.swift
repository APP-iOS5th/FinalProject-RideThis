import Foundation
import Combine

class SignUpInfoViewModel {
    private let firebaseService = FireBaseService()
    private let userService = UserService.shared
    private var cancellable = Set<AnyCancellable>()
    
    @Published var emailText: String = ""
    @Published var nickNameText: String = "" {
        didSet {
            if nickNameText.count > 7 {
                nickNameText = String(nickNameText.prefix(7))
            }
        }
    }
    @Published var weightText: String = ""
    
    @Published var allFieldFilled: Bool = false
    @Published var emailTextIsFilled: Bool = false
    @Published var nickNameTextIsFilled: Bool = false
    @Published var weightTextIsFilled: Bool = false
    
    @Published var isExistEmail: Bool = false
    @Published var isExistNickName: Bool = false
    @Published var weightWarningText: String? = nil
    
    init() {
        
        self.$nickNameText
            .removeDuplicates()
            .map{ !$0.isEmpty }
            .assign(to: &$nickNameTextIsFilled)
        
        self.$weightText
            .removeDuplicates()
            .map { !$0.isEmpty && (Int($0) ?? 0) > 10 }
            .assign(to: &$weightTextIsFilled)
        
        self.$weightText
            .removeDuplicates()
            .map { weightText -> String? in
                if let weight = Int(weightText), weight <= 10 {
                    return "몸무게는 10kg 초과여야 합니다."
                } else {
                    return nil
                }
            }
            .assign(to: &$weightWarningText)
        
        self.$nickNameText
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self = self else { return }
                Task {
                    let existCount = await self.firebaseService.findUser(nickName: text)
                    self.isExistNickName = existCount > 0 && UserService.shared.combineUser?.user_nickname != text
                }
            }
            .store(in: &cancellable)
        
        self.$emailText
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] email in
                guard let self = self else { return }
                if !email.isEmpty {
                    Task {
                        let existCount = await self.firebaseService.findUserCountBy(email: email)
                        self.isExistEmail = existCount > 0 && UserService.shared.combineUser?.user_email != email
                    }
                } else {
                    self.isExistEmail = false
                }
            }
            .store(in: &cancellable)
        
        Publishers.CombineLatest4($nickNameTextIsFilled, $weightTextIsFilled, $isExistNickName, $isExistEmail)
            .map { $0 && $1 && !$2 && !$3}
            .assign(to: &$allFieldFilled)
    }
    
    func createUser(userInfo: [String: Any], completion: @escaping (User) -> Void) {
        firebaseService.createUser(userInfo: userInfo) { user in
            completion(user)
        }
    }
}
