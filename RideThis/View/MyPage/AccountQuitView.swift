import UIKit
import SnapKit

class AccountQuitView: RideThisViewController {
    
    private lazy var logoImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "logo")
        image.contentMode = .scaleAspectFit
        let widthAndHeight = self.view.frame.width - 100
        image.widthAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        image.heightAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        
        return image
    }()
    private let nickNameLabel = RideThisLabel(fontType: .classification, text: "매드카우 회원님,")
    private let nickNameLabel2 = RideThisLabel(fontType: .classification, text: "정말 탈퇴하시겠습니까?")
    private let quitMessagelabel = RideThisLabel(fontType: .defaultSize, text: "탈퇴하시면 그동안의 랭킹, 기록, 장치연결 정보 및 친구 목록 등 모든 정보가 삭제됩니다.")
    private lazy var confirmCheckbox: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tag = 0
        btn.setImage(UIImage(systemName: "square"), for: .normal) // checkmark.square
        btn.tintColor = .label
        btn.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            
            if btn.tag == 0 {
                self.confirmCheckbox.tag = 1
                DispatchQueue.main.async {
                    self.confirmCheckbox.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                }
            } else {
                self.confirmCheckbox.tag = 0
                DispatchQueue.main.async {
                    self.confirmCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
                }
            }
        }, for: .touchUpInside)
        
        return btn
    }()
    private let confirmMessageLabel = RideThisLabel(fontType: .smallTitle, text: "유의사항을 모두 확인했으며, 이에 동의합니다.")
    private lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("취소", for: .normal)
        btn.widthAnchor.constraint(equalToConstant: 150).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.backgroundColor = .lightGray
        btn.layer.cornerRadius = 13
        btn.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)
        
        return btn
    }()
    // MARK: TODO - confirmCheckbox가 체크 되어있을 때 활성화
    private let quitButton = RideThisButton(buttonTitle: "회원 탈퇴", height: 50)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "회원탈퇴"
        configureUI()
    }
    
    func configureUI() {
        setLogoImage()
        setQuitMessageLabel()
        setQuitButton()
    }
    
    func setLogoImage() {
        self.view.addSubview(self.logoImage)
        
        self.logoImage.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(50)
            $0.centerX.equalTo(self.view.snp.centerX)
        }
    }
    
    func setQuitMessageLabel() {
        [self.nickNameLabel, self.nickNameLabel2, self.quitMessagelabel,
         self.confirmCheckbox, self.confirmMessageLabel].forEach{ self.view.addSubview($0) }
        quitMessagelabel.numberOfLines = 0
        
        self.nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(self.logoImage.snp.bottom).offset(40)
            $0.left.equalTo(self.view.snp.left).offset(40)
        }
        
        self.nickNameLabel2.snp.makeConstraints {
            $0.top.equalTo(self.nickNameLabel.snp.bottom)
            $0.left.equalTo(self.nickNameLabel.snp.left)
        }
        
        self.quitMessagelabel.snp.makeConstraints {
            $0.top.equalTo(self.nickNameLabel2.snp.bottom).offset(10)
            $0.left.equalTo(self.nickNameLabel.snp.left)
            $0.right.equalTo(self.view.snp.right).offset(-40)
        }
        
        self.confirmCheckbox.snp.makeConstraints {
            $0.top.equalTo(self.quitMessagelabel.snp.bottom).offset(20)
            $0.left.equalTo(self.quitMessagelabel.snp.left)
        }
        
        self.confirmMessageLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.confirmCheckbox.snp.centerY)
            $0.left.equalTo(self.confirmCheckbox.snp.right).offset(5)
        }
    }
    
    func setQuitButton() {
        [self.cancelButton, self.quitButton].forEach{ self.view.addSubview($0) }
        
        self.cancelButton.snp.makeConstraints {
            $0.top.equalTo(self.confirmCheckbox.snp.bottom).offset(20)
            $0.right.equalTo(self.view.snp.centerX).offset(-10)
        }
        
        self.quitButton.snp.makeConstraints {
            $0.top.equalTo(self.cancelButton.snp.top)
            $0.left.equalTo(self.view.snp.centerX).offset(10)
            $0.width.equalTo(self.cancelButton.snp.width)
        }
    }
}
