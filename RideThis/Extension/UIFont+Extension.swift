import UIKit

/// Font를 일일히 입력하지 않고 구분지어서 동일하게 사용하기 위해 생성함 근데 네이밍이... 좀 그렇다.
enum FontCase: CGFloat {
    /// size: 17, weight: .regular
    case defaultSize = 17
    /// size: 34, weight: .bold
    case title = 34
    /// size: 22, weight: .medium
    case sectionTitle = 22
    /// size: 13, weight: .regular
    case smallTitle = 13
    /// size: 12, weight: .semibold
    case infoMessage = 12
    /// size: 24, weight: .heavy
    case buttonSize = 24
    /// size: 350, weight: .bold
    case countDownSize = 350
    /// size: 20, weight: .semibold
    case classification = 20
    /// size: 28, weight: .semibold
    case recordInfoTitle = 28
    /// size: 64, weight: .bold
    case timerText = 64
    /// size: 18, weight: .bold
    case profileFont = 18
    /// size: 38, weight: .bold
    case signUpFont = 38
    case summaryInfo = 33
    case recordTitle = 18.01
    case recordInfo = 24.01
    
    var fontWeight: UIFont.Weight {
        get {
            switch self {
            case .defaultSize, .smallTitle:
                return .regular
            case .title, .countDownSize, .timerText, .summaryInfo, .recordInfo, .signUpFont:
                return .bold
            case .sectionTitle:
                return .medium
            case .infoMessage, .recordInfoTitle, .classification, .recordTitle:
                return .semibold
            case .buttonSize:
                return .heavy
            case .profileFont:
                return .bold
            }
        }
    }
}
