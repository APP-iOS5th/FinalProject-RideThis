import UIKit

/// 주색으로 설정된 버튼, width는 Float가 아닌 leading, trailing Anchor로 설정하고 height를 직접입력해서 사용함(이래도 되나..? 아닌거 같으면 Constraint로 설정할 것 figma에서 가장 흔하게 사용된 height가 50이라 기본값으로 설정)
class RideThisButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureButton()
    }
    
    // Button을 생성할 때 parameter로 여러가지 설정 가능, 추가하고 싶은게 있으면 얼마든지 추가 하세여(추가할 때 알려만 주시면 됩니다)
    convenience init(
        buttonTitle: String,
        height: CGFloat = 50
    ) {
        self.init()
        
        self.setTitle(buttonTitle, for: .normal)
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func configureButton() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 13
        self.backgroundColor = .primaryColor
        self.setTitleColor(.white, for: .normal)
    }
}
