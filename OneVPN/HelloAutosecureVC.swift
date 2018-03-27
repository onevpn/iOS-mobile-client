import UIKit

class HelloAutosecureVC: TransparentNavbarVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    fileprivate func proceedToNext() -> Void {
        
        self.performSegue(withIdentifier: "showHelloConfigScreen", sender: self)
    }

    @IBAction func enableClicked(_ sender: Any) {
        Settings.shared.autoSecureEnabled = true
        self.proceedToNext()
    }
    
    @IBAction func disableClicked(_ sender: Any) {
        Settings.shared.autoSecureEnabled = false
        self.proceedToNext()
    }

}
