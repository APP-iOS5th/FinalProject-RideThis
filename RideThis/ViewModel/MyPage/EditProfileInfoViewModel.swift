import Foundation
import Combine

class EditProfileInfoViewModel {
    private var cancellable = Set<AnyCancellable>()
    private let firebaseService = FireBaseService()
    
    @Published var nickName: String = ""
    @Published var weight: String = ""
    
    @Published var allFieldFilled: Bool = false
    @Published var nickNameFilled: Bool = false
    @Published var weightFilled: Bool = false
    
    @Published var isExistNickName: Bool = false
    
    @Published var warningMessage: String = ""
    
    init() {
        self.$nickName
            .removeDuplicates()
            .map { text in
                !text.isEmpty
            }
            .assign(to: &$nickNameFilled)
        
        self.$weight
            .map{ !$0.isEmpty }
            .assign(to: &$weightFilled)
        
        self.$weight
            .map { weightText -> String in
                if let weight = Int(weightText), weight <= 10 {
                    return "몸무게는 10kg 초과여야 합니다."
                } else {
                    return ""
                }
            }
            .assign(to: &$warningMessage)
        
        self.$nickName
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
        
        Publishers.CombineLatest4($nickNameFilled, $weightFilled, $isExistNickName, $warningMessage)
            .map { $0 && $1 && !$2 && $3.isEmpty }
            .assign(to: &$allFieldFilled)
    }
}
