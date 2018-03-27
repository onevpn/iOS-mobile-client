import UIKit
import AlamofireImage
import Eureka
import Alamofire

class ServerCell: Cell<Int>, CellType {

    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var pingLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    func configureCell(server: Server) -> Void {
        
        self.countryLabel.text = (server.emoji ?? "") + " " + (server.name ?? "")
        let ping = server.ping
        if (ping != nil) {
			let d: CGFloat = 255
            self.pingLabel.text = "\(ping!)"
            if (ping! > 600) {
                self.stateView.backgroundColor = UIColor(red: 209/d, green: 81/d, blue: 76/d, alpha: 1)
            } else if (ping! > 300) {
                self.stateView.backgroundColor = UIColor(red: 231/d, green: 204/d, blue: 97/d, alpha: 1)
            } else {
                self.stateView.backgroundColor = UIColor(red: 98/d, green: 183/d, blue: 112/d, alpha: 1)
            }
        }
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        Alert().showInfo("Add to favorites", subTitle: "Under construction")
    }
    
    public override func setup() {
        super.setup()
    }
    
    public override func update() {
        super.update()
    }
    
}

final class ServerRow: Row<ServerCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ServerCell>(nibName: "ServerCell")
    }
}
