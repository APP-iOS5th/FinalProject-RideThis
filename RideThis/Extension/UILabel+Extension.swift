import UIKit

/// 앱에서 주로 사용되는 Label을 쉽게 사용하기 위해 만든 class / 기본 폰트는 17px, regular이고, 파라미터(enum으로 생성한 FontCase와 색상)로 커스텀 및 Label에 들어갈 text도 설정할 수 있다.
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
    
    // Label을 생성할 때 parameter로 여러가지 설정 가능, 추가하고 싶은게 있으면 얼마든지 추가 하세여(추가할 때 알려만 주시면 됩니다)
    convenience init(
        fontType: FontCase = .defaultSize,
        fontColor: UIColor = .label,
        text: String = ""
    ) {
        self.init()
        
        self.font = UIFont.systemFont(ofSize: fontType.rawValue, weight: fontType.fontWeight)
        self.textColor = fontColor
        self.text = text
    }
    
    func configureLabel() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
