import UIKit
import PlainPing
import Eureka

class ServersVC: FormViewController {
    
    var servers: [Server]!
    var selectedServer: Server?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isHeroEnabled = true
		self.tableView?.rowHeight = 60
		self.tableView?.separatorColor = .white
		
        let section = Section()
        section.header = nil
        
        form +++ section
        
        for server in self.servers {
            section <<< ServerRow() { row in
                //
            }.onCellSelection({ (cell, row) in
                self.selectedServer = server
				Analytics.sendAction(action: AnalyticsActions.selectServer)
                self.performSegue(withIdentifier: "unwindToMain", sender: self)
            }).cellSetup({ (cell, row) in
                cell.separatorInset = UIEdgeInsets.zero
            }).cellUpdate({ (cell, row) in
                cell.configureCell(server: server)
            })
        }
    }
	
	override func viewWillAppear(_ animated: Bool) {
		
		guard let tracker = GAI.sharedInstance().defaultTracker else { return }
		tracker.set(kGAIScreenName, value: "Servers")
		
		guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
		tracker.send(builder.build() as [NSObject : AnyObject])
		
	}
    
    override func viewDidAppear(_ animated: Bool) {
        self.pingServerAtIndex(index: 0)
    }
    
    func pingServerAtIndex(index: Int) {
        
        if (index >= self.servers.count || !self.isViewLoaded) {
            return;
        }
        
        let server = self.servers[index]
        
        PlainPing.ping(server.host!) { (ping, error) in
            if (error == nil)
            {
                let latency = Int(ping!)
                server.ping = latency
                self.tableView?.reloadData()
            }
            self.pingServerAtIndex(index: index + 1)
        }
        
    }

    @IBAction func doneButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    class func segueIdentifier() -> String {
        return String(describing: self)
    }

}
