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
        
        Publishers.CombineLatest3($nickNameTextIsFilled, $weightTextIsFilled, $isExistNickName)
            .map { $0 && $1 && !$2}
            .assign(to: &$allFieldFilled)
    }
    
    func createUser(userInfo: [String: Any]) {
        firebaseService.createUser(userInfo: userInfo) { [weak self] user in
            guard let self = self else { return }
            UserService.shared.signedUser = user
        }
    }
}
