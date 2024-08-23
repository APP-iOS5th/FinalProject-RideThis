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

class CustomSeparator: UIView {
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
        self.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}

// UIView Background Gridiant추가
extension UIView{
    func setGradient(color1:UIColor,color2:UIColor){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [color1.cgColor,color2.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = bounds
        // layer.addSublayer(gradient)
        
        if let firstLayer = layer.sublayers?.first, firstLayer is CAGradientLayer {
            firstLayer.removeFromSuperlayer()
        }
        layer.insertSublayer(gradient, at: 0)
    }
}
