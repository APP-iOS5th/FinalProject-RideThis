import UIKit

/// Figma에서 정의한 기본 Container 기록 / 경쟁의 각 저장 데이터 및 마이페이지의 정보 등에서 사용됨
class RideThisContainer: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContainer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureContainer()
    }
    
    convenience init(
        height: CGFloat = 150
    ) {
        self.init()
        
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func configureContainer() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.layer.cornerRadius = 13
    }
}

/// 기록 / 경쟁에서 Title과 데이터 사이를 구분짓는 구분선
class RideThisSeparator: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSeperator()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSeperator()
    }
    
    func configureSeperator() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .primaryColor
        self.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}
