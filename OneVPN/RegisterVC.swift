import UIKit

class RegisterVC: TransparentNavbarVC {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signUpButtonMargin: NSLayoutConstraint!
    
    var defaultSignUpButtonMargin: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultSignUpButtonMargin = self.signUpButtonMargin.constant
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		
		guard let tracker = GAI.sharedInstance().defaultTracker else { return }
		tracker.set(kGAIScreenName, value: "Sign Up")
		
		guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
		tracker.send(builder.build() as [NSObject : AnyObject])
		
	}
	
    override func viewDidAppear(_ animated: Bool) {
        self.emailField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        
        self.emailField.resignFirstResponder()
        
        let email = self.emailField.text!
		
		Analytics.sendAction(action: AnalyticsActions.signUp)
		
        API.shared.register(email: email) { (success) in
            
            if (success) {
				
                Account.shared.username = email
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let signUpButtonBottomOffset = UIScreen.main.bounds.height - self.signupButton.frame.maxY
        if  (keyboardHeight > signUpButtonBottomOffset) {
            self.signUpButtonMargin.constant = 4
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.signUpButtonMargin.constant = self.defaultSignUpButtonMargin
    }
}
