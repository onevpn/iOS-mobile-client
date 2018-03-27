import UIKit
import Eureka
import SafariServices
import Localize_Swift

class AccountVC: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isHeroEnabled = true
        
        let account = Account.shared
        
        form +++ Section("Traffic".localized())
            <<< LabelRow(){ row in
                row.title = "⬇️ " + "In:".localized().appending(" \(account.traffic_in)")
            }
            <<< LabelRow(){ row in
                row.title = "⬆️ " + "Out:".localized().appending(" \(account.traffic_out)")
            }
            <<< LabelRow(){ row in
                row.title = "Total:".localized().appending(" \(account.traffic_total)")
            }
            <<< LabelRow(){ row in
                row.title = "Limit:".localized().appending(" \(account.traffic_limit)")
            }
            +++ Section("Plan info".localized())
            <<< LabelRow(){ row in
                row.title = account.plan_name
            }
            <<< LabelRow(){ row in
                row.title = "⌛️ " + "Days left:".localized().appending(" \(account.plan_expires/60/60/24)")
            }
            +++ Section("Account".localized())
            <<< LabelRow(){ row in
                row.title = "👤 " + Account.shared.username
            }
            <<< ButtonRow(){ row in
                row.title = "🚪 " + "Logout".localized()
            }.onCellSelection({ (cell, row) in
                self.logout()
            })
    }
	
	override func viewWillAppear(_ animated: Bool) {
		
		guard let tracker = GAI.sharedInstance().defaultTracker else { return }
		tracker.set(kGAIScreenName, value: "Account")
		
		guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
		tracker.send(builder.build() as [NSObject : AnyObject])
		
	}
	
    func logout() -> Void {
		
		Analytics.sendAction(action: AnalyticsActions.signOut)
        Account.shared.clear()
        self.dismiss(animated: false, completion: nil)
        StartVC.showStartScreen(from: self.presentingViewController!)
    }
	
	class func storyboardId() -> String {
		return "AccountVC"
	}

}
