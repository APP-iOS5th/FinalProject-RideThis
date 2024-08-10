import UIKit

/// Font를 일일히 입력하지 않고 구분지어서 동일하게 사용하기 위해 생성함 근데 네이밍이... 좀 그렇다.
enum FontCase: CGFloat {
    case defaultSize = 17
    case title = 34
    case sectionTitle = 22
    case smallTitle = 13
    case infoMessage = 12
    case buttonSize = 24
    case countDownSize = 350
    case countDownText = 20
    case recordInfoTitle = 28
    case timerText = 64
    case profileFont = 18
    
    var fontWeight: UIFont.Weight {
        get {
            switch self {
            case .defaultSize, .smallTitle, .countDownText:
                return .regular
            case .title, .countDownSize, .timerText:
                return .bold
            case .sectionTitle:
                return .medium
            case .infoMessage, .recordInfoTitle:
                return .semibold
            case .buttonSize:
                return .heavy
            case .profileFont:
                return .bold
            }
        }
    }
}
