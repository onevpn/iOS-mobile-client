import UIKit

class HelloAllowConfigVC: TransparentNavbarVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func continueClicked(_ sender: Any) {
        
        Network.shared.updateVpnConfig(server: API.shared.cachedServers.first!) { 
            
            Settings.shared.skipLoginGuides = true
            LoginVC.showMainScreen(fromViewController: self)
			
        }
		
    }

}
