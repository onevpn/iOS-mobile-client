import UIKit
import AlamofireNetworkActivityIndicator
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var customWindow: OneWindow?
    var window: UIWindow? {
        get {
            customWindow = customWindow ?? OneWindow(frame: UIScreen.main.bounds)
            return customWindow
        }
        set {}
    }
    var showPasswordLockIfEnabled = true

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		Fabric.with([Crashlytics.self])
		
		if let gai = GAI.sharedInstance() {
			gai.tracker(withTrackingId: "GAI_tracking_ID")
		}

        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.startDelay = 0.5
        NetworkActivityIndicatorManager.shared.completionDelay = 0.5
        
        var storyboardName = "Main"
        if Account.shared.isLoaded == false {
            storyboardName = "Login"
            let oneWindow = self.window as? OneWindow
            oneWindow?.backgroundView.isHidden = false
        }
        
        self.window?.rootViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController()
        
        let brandColor1 = #colorLiteral(red: 0.1529411765, green: 0.8156862745, blue: 0.7803921569, alpha: 1)
        
        UIButton.appearance(whenContainedInInstancesOf: [TransparentNavbarVC.self]).tintColor = brandColor1
        
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {}

	func applicationDidEnterBackground(_ application: UIApplication) {
        showPasswordLockIfEnabled = true
    }

	func applicationWillEnterForeground(_ application: UIApplication) {}

	func applicationDidBecomeActive(_ application: UIApplication) {
        if showPasswordLockIfEnabled && Account.shared.isPasswordEnabled && Account.shared.unlockPassword.characters.count > 0 {
            var vc = self.window?.rootViewController
            if vc?.presentedViewController != nil {
                vc = vc?.presentedViewController
            }
            showPasswordLockIfEnabled = false
            LockVC.showInVC(viewController: vc!)
        }
    }

	func applicationWillTerminate(_ application: UIApplication) {}
}

class OneWindow: UIWindow {
    
    var backgroundView: UIImageView!
    var overlayView: UIView!
    
    override required init(frame: CGRect) {
        super.init(frame: frame)
        
        let width = frame.width
        
        var logoSize = width/2
        var bgImage = "bg_phone"
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            logoSize = width * 0.75
            break
        case .pad:
            logoSize = width * 0.3
            bgImage = "bg_pad"
            break
        default:
            break
        }
        
        self.backgroundView = UIImageView(frame: frame)
        self.backgroundView.image = UIImage(named: bgImage)
        
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "logo")
        logoImageView.frame = CGRect(x: width/2 - logoSize/2, y: logoSize/2, width: logoSize, height: logoSize)
        self.backgroundView.addSubview(logoImageView)
        
        self.overlayView = UIView(frame: frame)
        self.overlayView.backgroundColor = UIColor.init(white: 0, alpha: 0.666)
        self.overlayView.isHidden = true
        self.overlayView.alpha = 0
        self.backgroundView.addSubview(overlayView)
        
        self.backgroundView.isHidden = true
        self.addSubview(self.backgroundView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func showBackgroundView() -> Void {
        let window = UIApplication.shared.keyWindow as? OneWindow
        window?.backgroundView.isHidden = false
    }
    
    class func hideBackgroundView() -> Void {
        let window = UIApplication.shared.keyWindow as? OneWindow
        window?.backgroundView.isHidden = true
    }

    class func showOverlayView() -> Void {
        let window = UIApplication.shared.keyWindow as? OneWindow
        window?.overlayView.isHidden = false
        UIView.animate(withDuration: 0.25) { 
            window?.overlayView.alpha = 1
        }
    }

    class func hideOverlayView() -> Void {
        let window = UIApplication.shared.keyWindow as? OneWindow
        UIView.animate(withDuration: 0.25, animations: { 
             window?.overlayView.alpha = 0
        }) { (finished) in
            window?.overlayView.isHidden = true
        }
    }
}

