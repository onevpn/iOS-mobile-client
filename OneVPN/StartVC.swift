import UIKit

class StartVC: TransparentNavbarVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isHeroEnabled = true
        self.navigationController?.heroNavigationAnimationType = .zoom
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        OneWindow.hideOverlayView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        OneWindow.showOverlayView()
    }
    
    class func showStartScreen(from viewController: UIViewController) -> Void {
        
        OneWindow.showBackgroundView()
        
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let authVC = loginStoryboard.instantiateInitialViewController()
        viewController.present(authVC!, animated: true, completion: nil)
        authVC?.setNeedsStatusBarAppearanceUpdate()
    }

}
