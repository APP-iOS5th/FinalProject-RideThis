import UIKit


enum FontCase: CGFloat {

    case defaultSize = 17

    case title = 34

    case subTitle = 26

    case sectionTitle = 22

    case smallTitle = 13

    case infoMessage = 12

    case buttonSize = 24

    case countDownSize = 350

    case classification = 20

    case recordInfoTitle = 28

    case timerText = 64

    case profileFont = 18

    case signUpFont = 38
    case summaryInfo = 33
    case recordTitle = 18.01
    case recordInfo = 24.01
    case profileFont2 = 15
    
    var fontWeight: UIFont.Weight {
        get {
            switch self {
            case .defaultSize, .smallTitle:
                return .regular
            case .title, .subTitle, .countDownSize, .timerText, .summaryInfo, .recordInfo, .signUpFont:
                return .bold
            case .sectionTitle:
                return .medium
            case .infoMessage, .recordInfoTitle, .classification, .recordTitle:
                return .semibold
            case .buttonSize:
                return .heavy
            case .profileFont, .profileFont2:
                return .bold
            }
        }
    }
}
