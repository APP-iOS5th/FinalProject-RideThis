import Foundation
import Combine

class SignUpInfoViewModel {
    private let firebaseService = FireBaseService()
    private let userService = UserService.shared
    private var cancellable = Set<AnyCancellable>()
    
    @Published var emailText: String = ""
    @Published var nickNameText: String = ""
    @Published var weightText: String = ""
    
    @Published var allFieldFilled: Bool = false
    @Published var emailTextIsFilled: Bool = false
    @Published var nickNameTextIsFilled: Bool = false
    @Published var weightTextIsFilled: Bool = false
    
    @Published var isExistNickName: Bool = false
    
    init() {
        self.$emailText
            .removeDuplicates()
            .map{ !$0.isEmpty }
            .assign(to: &$emailTextIsFilled)
        
        self.$nickNameText
            .removeDuplicates()
            .map{ !$0.isEmpty }
            .assign(to: &$nickNameTextIsFilled)
        
        self.$weightText
            .removeDuplicates()
            .map{ !$0.isEmpty }
            .assign(to: &$weightTextIsFilled)
        
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
        
        Publishers.CombineLatest4($emailTextIsFilled, $nickNameTextIsFilled, $weightTextIsFilled, $isExistNickName)
            .map { $0 && $1 && $2 && !$3}
            .assign(to: &$allFieldFilled)
    }
    
    func createUser(userInfo: [String: Any]) {
        firebaseService.createUser(userInfo: userInfo) { [weak self] user in
            guard let self = self else { return }
            UserService.shared.signedUser = user
        }
    }
}
