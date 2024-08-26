import Foundation
import Combine

class SignUpInfoViewModel {
    @Published var emailText: String = ""
    @Published var nickNameText: String = ""
    @Published var weightText: String = ""
    
    @Published var allFieldFilled: Bool = false
    @Published var emailTextIsFilled: Bool = false
    @Published var nickNameTextIsFilled: Bool = false
    @Published var weightTextIsFilled: Bool = false
    
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
        
        Publishers.CombineLatest3($emailTextIsFilled, $nickNameTextIsFilled, $weightTextIsFilled)
            .map { $0 && $1 && $2 }
            .assign(to: &$allFieldFilled)
    }
}
