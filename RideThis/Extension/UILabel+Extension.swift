import UIKit

class RideThisLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLabel()
    }
    
    let initialFontType: FontCase = .defaultSize
    
    convenience init(
        fontType: FontCase = .defaultSize,
        fontColor: UIColor = .label,
        text: String = ""
    ) {
        self.init()
        
        if fontType == .timerText {
            self.font = UIFont.monospacedDigitSystemFont(ofSize: fontType.rawValue, weight: fontType.fontWeight)
        } else {
            self.font = UIFont.systemFont(ofSize: fontType.rawValue, weight: fontType.fontWeight)
        }
        self.textColor = fontColor
        self.text = text
    }
    
    func configureLabel() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
    }
}
