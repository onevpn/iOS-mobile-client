import UIKit
import NVActivityIndicatorView
import Hero
import Localize_Swift

fileprivate enum vpnButtonState {
    case connected
    case connecting
    case disconnected
}

class MainVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var serverButton: UIButton!
    @IBOutlet weak var vpnButton: UIButton!
    @IBOutlet weak var ipButton: UIButton!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    
    var servers: [Server] = []
    
    private var selectedServer: Server?
    private var startOverAfterDisconnect = false
    private var previousIP: String = ""
    private var accountVC: AccountVC!
    private var settingsVC: SettingsVC!
    private var isUpdatingIP = false
    private var gradientView: GradientView!
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(red: 47/255, green: 53/255, blue: 62/255, alpha: 1)
        
        self.serverButton.backgroundColor = UIColor(white: 0, alpha: 0.33)
        self.serverButton.layer.cornerRadius = 8
        self.serverButton.clipsToBounds = true
        
        self.drawVpnButtonGradient()
        
        self.servers = API.shared.cachedServers
        
        self.loadSelectedServerFromCurrentConfig(completion: {
            if self.selectedServer == nil {
                self.selectedServer = API.shared.cachedServers.first
                self.updateServerButtonTitle()
            }
        })
        
        self.isHeroEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.vpnStatusChanged), name: NSNotification.Name(rawValue: kVpnStatusChangedNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.settingHasChanged), name: NSNotification.Name(rawValue: kSettingsUpdatedNotificationName), object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
	
	override func viewWillAppear(_ animated: Bool) {
		
		guard let tracker = GAI.sharedInstance().defaultTracker else { return }
		tracker.set(kGAIScreenName, value: "VPN")
		
		guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
		tracker.send(builder.build() as [NSObject : AnyObject])
		
	}
	
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateExternalIP()
        self.updateUIForReachabilityStatus()
        self.gradientView.center = self.vpnButton.center
        self.gradientView.isHidden = false
    }
    
    fileprivate func drawVpnButtonGradient() -> Void {
        
        let frame = self.vpnButton.frame
        let margin: CGFloat = 10.0
        self.gradientView = GradientView(frame: CGRect(x: 0, y: 0, width: frame.width-margin, height: frame.height-margin))
        self.view.insertSubview(self.gradientView, belowSubview: self.vpnButton)
        self.gradientView.isHidden = true
    }
    
    
    fileprivate func setVpnButtonState(state: vpnButtonState) {
        
        switch state {
            case .connected:
                self.vpnButton.layer.removeAllAnimations()
                self.vpnButton.alpha = 1.0
            break
            
            case .connecting:
                UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
                    self.vpnButton.alpha = 0.25
                })
            break
            
            case .disconnected:
                self.vpnButton.layer.removeAllAnimations()
                self.vpnButton.alpha = 1.0
            break
        }
    }
    
    
    fileprivate func updateUIForReachabilityStatus() {
        
        let status = Network.shared.reachabilityStatus()
        var title = ""
        let d: CGFloat = 255
        
        var color1 = UIColor(red: 241/d, green: 98/d, blue: 132/d, alpha: 1)
        var color2 = UIColor(red: 239/d, green: 141/d, blue: 228/d, alpha: 1)
        
        switch status {
            case .notReachable:
                title = "⛔️ " + "No internet".localized()
            break
            
            case .securedCell:
                title = "🔒✅ " + "Secured cellular".localized()
                color1 = UIColor(red: 60/d, green: 216/d, blue: 139/d, alpha: 1)
                color2 = UIColor(red: 39/d, green: 207/d, blue: 200/d, alpha: 1)
            break
            
            case .unsecuredCell:
                title = "🔓⛔️ " + "Unsecured cellular".localized()
                color1 = UIColor(red: 138/255, green: 119/d, blue: 231/d, alpha: 1)
                color2 = UIColor(red: 216/d, green: 120/d, blue: 181/d, alpha: 1)
            break
            
            case .securedWifi:
                title = "🔒✅ " + "Secured Wifi".localized()
                color1 = UIColor(red: 93/d, green: 127/d, blue: 195/d, alpha: 1)
                color2 = UIColor(red: 74/d, green: 190/d, blue: 236/d, alpha: 1)
            break;
            
            case .unsecuredWifi:
                title = "🔓⛔️ " + "Unsecured Wifi".localized()
                color1 = UIColor(red: 218/d, green: 86/d, blue: 122/d, alpha: 1)
                color2 = UIColor(red: 250/d, green: 213/d, blue: 141/d, alpha: 1)
				Analytics.sendAction(action: AnalyticsActions.unprotectedWifi)
            break
            
            case .securedTrustedWifi:
                title = "🔒✅ " + "Secured trusted Wifi".localized()
                color1 = UIColor(red: 60/d, green: 216/d, blue: 139/d, alpha: 1)
                color2 = UIColor(red: 39/d, green: 207/d, blue: 200/d, alpha: 1)
            break
            
            case .unsecuredTrustedWifi:
                title = "🔓⛔️ " + "Unsecured trusted Wifi".localized()
                color1 = UIColor(red: 157/d, green: 184/d, blue: 199/d, alpha: 1)
                color2 = UIColor(red: 110/d, green: 143/d, blue: 160/d, alpha: 1)
            break
        }
        
        self.connectionStatusLabel.text = title
        self.gradientView.fill(with: color1, color2: color2)
    }
    
    @objc fileprivate func settingHasChanged() -> Void {
		
        if (self.selectedServer == nil) {
            return
        }
        
        self.updateCurrentVPN()
        
    }
    
    fileprivate func loadSelectedServerFromCurrentConfig(completion: (() -> Void)?) -> Void {
        
        Network.shared.extractServerFromConfig() { (server) in
            if server != nil {
                self.selectedServer = server
                self.updateServerButtonTitle()
            }
            completion?()
        }
    }
    
    fileprivate func updateCurrentVPN(completion: ((Bool) -> Void)? = nil) {
        
        if self.selectedServer == nil {
            completion?(false)
            return
        }
        
        Network.shared.updateVpnConfig(server: self.selectedServer!) {
            
			Settings.shared.lastServerImage = self.selectedServer?.emoji ?? ""
            self.updateServerButtonTitle()
            completion?(true)
        }
        
    }
    
    fileprivate func updateServerButtonTitle() {
        var serverName = self.selectedServer?.name ?? ""
        if let serverEmoji = Settings.shared.lastServerImage {
            serverName = serverEmoji + " " + serverName
        }
        
        self.serverButton.setTitle(serverName, for: .normal)
    }
    
    fileprivate func updateExternalIP(tillChanges: Bool = false) {
        
        if (self.isUpdatingIP) {
            return
        }
        
        self.ipButton.setTitle("Updating IP..".localized(), for: .normal)
        self.isUpdatingIP = true
        
        API.shared.getExternalIP { (externalIP) in
            self.isUpdatingIP = false
            if (externalIP == nil) {
                self.updateExternalIP(tillChanges: tillChanges)
            } else {
                self.ipButton.setTitle(externalIP, for: .normal)
                if (tillChanges && self.previousIP == externalIP) {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        self.updateExternalIP(tillChanges: true)
                    }
                }
            }
            self.previousIP = externalIP ?? ""
        }
    }
    
    fileprivate func startTunnelWithCurrentConfig() -> Void {
        
        if Network.shared.connectVPN() == false {
            self.setVpnButtonState(state: .disconnected)
        }
    }
    
    @objc fileprivate func vpnStatusChanged() {
        
        let status = Network.shared.vpnStatus()
        
        switch status {
            case .off:
                if (self.startOverAfterDisconnect) {
                    self.startOverAfterDisconnect = false
                    self.startTunnelWithCurrentConfig()
                } else {
                    self.setVpnButtonState(state: .disconnected)
                }
                self.updateUIForReachabilityStatus()
                break;
            case .processing:
                self.setVpnButtonState(state: .connecting)
                break;
            case .on:
                self.setVpnButtonState(state: .connected)
                self.updateExternalIP(tillChanges: true)
                self.updateUIForReachabilityStatus()
                break;
        }
    }
    
    @IBAction func ipButtonClicked(_ sender: UIButton) {
        self.updateExternalIP()
    }
    
    @IBAction func connectVPN(_ sender: UIButton) {
        
        if (self.selectedServer == nil) {
            Alert().showInfo("No server selected".localized(), subTitle: "Please select a server to connect to".localized())
            return
        }
		
		if Account.shared.plan_name == "Trial" {
			if Int32(Account.shared.traffic_total) >= Account.shared.traffic_limit {
				Alert().showNotice("Trial traffic limit".localized(), subTitle: "Plase upgrade your plan or get back next month".localized())
				return
			}
		} else if Account.shared.plan_expires == 0 {
			Alert().showNotice("Plan expired".localized(), subTitle: "Please add funds".localized())
			return
		}
		
        if (Network.shared.vpnStatus() == .on) {
			Analytics.sendAction(action: AnalyticsActions.vpnOff)
			if Settings.shared.autoSecureEnabled == true {
				Alert().showNotice("Autosecure will be turned off", subTitle: "Please re-enable it as soon as possible")
				Settings.shared.autoSecureEnabled = false
			}
            Network.shared.disconnectVPN()
            self.updateExternalIP(tillChanges: true)
        } else {
			Analytics.sendAction(action: AnalyticsActions.vpnOn)
            self.updateCurrentVPN( completion: { (success) in
                if (success) {
                    self.startTunnelWithCurrentConfig()
                } else {
                    sender.setTitle(":(((", for: UIControlState.normal)
                }
            })
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == ServersVC.segueIdentifier()) {
            if (self.servers.count == 0) {
                API.shared.getDataFromAPI(completion: { (servers) in
                    if (servers != nil) {
                        self.servers = servers!
                        self.performSegue(withIdentifier: identifier, sender: sender)
                    }
                    else
                    {
                        Alert().showError("Server loading error".localized(), subTitle: "Unable to load server list, please try again later".localized())
                    }
                })
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == ServersVC.segueIdentifier())
        {
            let navigationController = segue.destination as! UINavigationController
            let vc = navigationController.viewControllers.first as! ServersVC
            vc.servers = self.servers
        }
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        let vc = segue.source as! ServersVC
        self.selectedServer = vc.selectedServer
        self.updateCurrentVPN(completion: { (success) in
            if (Network.shared.vpnStatus() == .on) {
                Network.shared.disconnectVPN()
                self.startOverAfterDisconnect = true
            }
        })
    }

}

