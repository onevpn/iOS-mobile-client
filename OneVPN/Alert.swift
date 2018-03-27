import Foundation
import SCLAlertView

class Alert: SCLAlertView {

    required init() {
        let appearance = SCLAppearance()
        super.init(appearance: appearance)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
}
