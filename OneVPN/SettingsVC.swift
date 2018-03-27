import UIKit
import Eureka
import SmileLock
import LocalAuthentication
import Localize_Swift

let trustedWifiSectionTag = "trustedWifiSectionTag"
let passcodeRowTag = "passcodeRowTag"

class SettingsVC: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isHeroEnabled = true
        
        let touchIdSupported = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        form +++ Section(header: "AUTO-SECURE".localized(), footer: "Turn on to automatically secure connections to untrusted networks".localized())
            <<< SwitchRow() {
                $0.title = "Enable auto-secure".localized()
            }.onChange({ (row) in
                Settings.shared.autoSecureEnabled = row.value!
				if row.value == true {
					Analytics.sendAction(action: AnalyticsActions.autoconnectOn)
				} else {
					Analytics.sendAction(action: AnalyticsActions.autoconnectOff)
				}
            }).cellSetup({ (cell, row) in
                row.value = Settings.shared.autoSecureEnabled
            })
            +++ Section(header: "Trusted networks".localized(), footer: "Add a network to trusted, so autosecure would ignore it".localized()) { section in
                section.tag = trustedWifiSectionTag
            }
            +++ Section("Security".localized())
            <<< SwitchRow(passcodeRowTag) { row in
                row.title = "Passcode lock".localized()
                row.value = Account.shared.isPasswordEnabled && Account.shared.unlockPassword.characters.count > 0
            }.onChange({ (row) in
                let flag = row.value!
                Account.shared.isPasswordEnabled = flag
                Account.shared.isTouchIdEnabled = false
                self.showPasswordInput()
            })
            <<< SwitchRow("touchIdRowTag") {row in
                row.value = Account.shared.isTouchIdEnabled
                row.hidden = Condition.function([passcodeRowTag], { form in
                    return !((form.rowBy(tag: passcodeRowTag) as? SwitchRow)?.value ?? false && touchIdSupported)
                })
                row.title = "TouchID enabled".localized()
            }.onChange({ (row) in
                Account.shared.isTouchIdEnabled = row.value!
            })
            +++ Section("Cell".localized())
            <<< SwitchRow() { row in
                row.title = "Trust cellular".localized()
                row.value = Settings.shared.trustCellNetwork
            }.onChange({ (row) in
                Settings.shared.trustCellNetwork = row.value!
            })
        
        self.fillTrustedWifiSection()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		
		guard let tracker = GAI.sharedInstance().defaultTracker else { return }
		tracker.set(kGAIScreenName, value: "Settings")
		
		guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
		tracker.send(builder.build() as [NSObject : AnyObject])
		
	}
	
    func fillTrustedWifiSection() -> Void {
        let trustedSection = form.sectionBy(tag: trustedWifiSectionTag)!
        trustedSection.removeAll()
        for ssid in Settings.shared.trustedSSIDs {
            let row = LabelRow() { row in
                row.title = ssid
            }.onCellSelection({ (cell, row) in
                let alert = Alert()
                alert.addButton("Yes".localized()) {
                    if (Settings.stopTrustingSSID(ssid: row.title!)) {
                        row.section?.remove(at: (row.indexPath?.row)!)
                    }
                }
                alert.showWarning("Confirm action".localized(), subTitle: "Do you really want to remove the SSID from trusted?".localized(), closeButtonTitle: "No".localized())
            }).cellSetup({ (cell, row) in
				cell.accessoryType = .disclosureIndicator
			})
            trustedSection <<< row
        }
        trustedSection <<< ButtonRow() { row in
            row.title = "Add trusted Wifi".localized()
            }.onCellSelection({ (cell, row) in
                let alert = Alert()
                let txt = alert.addTextField("Enter Wifi SSID".localized())
                alert.addButton("Add to trusted".localized()) {
                    if let ssid = txt.text {
						Analytics.sendAction(action: AnalyticsActions.wifiWhiteList)
                        if Settings.startTrustingSSID(ssid: ssid) {
                            self.fillTrustedWifiSection()
                        }
                    }
                }
                alert.showEdit("Enter network name".localized(), subTitle: "And it will be added to trusted".localized(), closeButtonTitle: "Cancel".localized())
            })
    }
    
    func showPasswordInput() -> Void {
        LockVC.showInVC(viewController: self)
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
	class func storyboardId() -> String {
		return "SettingsVC"
	}
	
}
