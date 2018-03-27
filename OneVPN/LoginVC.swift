import UIKit

class LoginVC: TransparentNavbarVC {

    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.text = Account.shared.username
    }
	
	override func viewWillAppear(_ animated: Bool) {
		
		guard let tracker = GAI.sharedInstance().defaultTracker else { return }
		tracker.set(kGAIScreenName, value: "Sign In")
		
		guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
		tracker.send(builder.build() as [NSObject : AnyObject])
		
	}
    
    override func viewDidAppear(_ animated: Bool) {
        if (self.emailField.text == "") {
            self.emailField.becomeFirstResponder()
        } else {
            self.passwordField.becomeFirstResponder()
        }
    }
    
    class func showMainScreen(fromViewController: UIViewController) -> Void {
        
        OneWindow.hideBackgroundView()
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = mainStoryboard.instantiateInitialViewController() as! MainVC
        
        mainVC.servers = API.shared.cachedServers
        
        fromViewController.present(mainVC, animated: true, completion: nil)
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        
        Account.shared.username = self.emailField.text!
        Account.shared.token = API.shared.generateToken(password: self.passwordField.text!)
        
        self.emailField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
		
		Analytics.sendAction(action: AnalyticsActions.signIn)
		
        API.shared.getDataFromAPI { (servers) in
            
            if servers != nil {
                API.shared.cachedServers = servers!
                if Settings.shared.skipLoginGuides {
                    LoginVC.showMainScreen(fromViewController: self)
                } else {
                    self.performSegue(withIdentifier: "showHelloScenario", sender: self)
                }
            }
        }
    }

    @IBAction func recoverPasswordButtonClicked(_ sender: Any) {
        let alert = Alert()
        let textField = alert.addTextField("Enter your email".localized())
        textField.text = self.emailField.text
        alert.addButton("Recover".localized()) {
            let email = textField.text ?? ""
            API.shared.recoverPassword(email: email, completion: { (success) in
                //
            })
        }
        alert.showEdit("Enter your email".localized(), subTitle: "New password will be sent to you".localized(), closeButtonTitle: "Cancel".localized())
    }
}
