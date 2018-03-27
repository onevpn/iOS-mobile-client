import UIKit
import SmileLock

class MyPasswordModel {
    class func match(_ password: String) -> MyPasswordModel? {
        let flag = Account.shared.isPasswordEnabled
        let current = Account.shared.unlockPassword
        if flag && current == "" {
            Account.shared.unlockPassword = password
            return MyPasswordModel()
        } else if !flag && password == current {
            Account.shared.unlockPassword = ""
            return MyPasswordModel()
        }
        guard password == current else { return nil }
        return MyPasswordModel()
    }
}

class MyPasswordUIValidation: PasswordUIValidation<MyPasswordModel> {
    init(in stackView: UIStackView) {
        super.init(in: stackView, digit: 4)
        validation = { password in
            MyPasswordModel.match(password)
        }
    }
    
    override func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            let dummyModel = MyPasswordModel()
            self.success?(dummyModel)
        } else {
            passwordContainerView.clearInput()
        }
    }
}

class LockVC: UIViewController {

    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var passwordUIValidation: MyPasswordUIValidation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordUIValidation = MyPasswordUIValidation(in: passwordStackView)
        
        passwordUIValidation.success = { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        
        passwordUIValidation.failure = { _ in
            
        }
        
        passwordUIValidation.view.rearrangeForVisualEffectView(in: self)
        passwordUIValidation.view.touchAuthenticationEnabled = Account.shared.isTouchIdEnabled
        
        if Account.shared.unlockPassword == "" {
            self.titleLabel.text = "Set password".localized()
        } else if Account.shared.isTouchIdEnabled {
            self.titleLabel.text = "Touch ID or enter password".localized()
		} else {
			self.titleLabel.text = "Enter password".localized()
		}
    }
    
    class func showInVC(viewController: UIViewController) -> Void {
        
        let lockVC = LockVC(nibName: "LockVC", bundle: nil)
        lockVC.modalPresentationStyle = .formSheet
        lockVC.modalTransitionStyle = .crossDissolve
        viewController.present(lockVC, animated: true, completion: nil)
    }

}
