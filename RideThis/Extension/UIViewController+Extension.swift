import UIKit

/// 팀에서 결정한 backgroundColor를 적용하기 위해 생성, 이 class를 상속받는 모든 view의 배경색은 primaryBackgroundColor(aka. 주황색)로 설정된다.
class RideThisViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .primaryBackgroundColor
        self.overrideUserInterfaceStyle = .light
    }
}

extension UIViewController {
    /// 쉽게 alert를 띄우기 위해 만든 함수 UIViewController를 상속한 모든 화면에서 사용 가능하다.
    func showAlert(alertTitle: String, msg: String? = nil, confirm: String, hideCancel: Bool? = false, confirmAction: (() -> Void)?, cancelAction: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: alertTitle, message: msg, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: confirm, style: .default) { _ in
            confirmAction?()
        }
        alertController.addAction(confirmAction)
        
        if hideCancel != true {
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                cancelAction?()
            }
            alertController.addAction(cancelAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
}
