import Combine

class EditProfileInfoViewModel {
    @Published var nickName: String = ""
    @Published var height: String = ""
    
    @Published var allFieldFilled: Bool = false
    @Published var nickNameFilled: Bool = false
    @Published var heightFilled: Bool = false
    
    init() {
        self.$nickName
            .removeDuplicates()
            .map{ !$0.isEmpty }
            .assign(to: &$nickNameFilled)
        
        self.$height
            .removeDuplicates()
            .map{ !$0.isEmpty }
            .assign(to: &$heightFilled)
        
        Publishers.CombineLatest($nickNameFilled, $heightFilled)
            .map { $0 && $1 }
            .assign(to: &$allFieldFilled)
    }
}
