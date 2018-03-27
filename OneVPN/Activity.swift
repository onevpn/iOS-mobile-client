import Foundation
import NVActivityIndicatorView

class Activity {
    
    class func startAnimating(message: String) -> Void {
        
        let animationTypeIndex = Int(arc4random_uniform(UInt32(NVActivityIndicatorType.audioEqualizer.rawValue - NVActivityIndicatorType.ballPulse.rawValue))) + NVActivityIndicatorType.ballPulse.rawValue
        
        let activityType = NVActivityIndicatorType(rawValue: animationTypeIndex)
        let backgroundColor = UIColor.init(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
		
		let colors = self.randomColorPair()
		let indicatorColor = colors.0
		let textColor = colors.1
		
		let activityData = ActivityData(message: message, type: activityType, color: indicatorColor, backgroundColor: backgroundColor, textColor: textColor)
		
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
	
	fileprivate class func randomColorPair() -> (UIColor, UIColor) {
		
		let d: CGFloat = 255.0
		var color1 = UIColor.white
		var color2 = UIColor.white
		
		let pairIndex = Int(arc4random_uniform(6))
		
		switch pairIndex {
		case 0:
			color1 = UIColor(red: 241/d, green: 98/d, blue: 132/d, alpha: 1)
			color2 = UIColor(red: 239/d, green: 141/d, blue: 228/d, alpha: 1)
			break
			
		case 1:
			color1 = UIColor(red: 60/d, green: 216/d, blue: 139/d, alpha: 1)
			color2 = UIColor(red: 39/d, green: 207/d, blue: 200/d, alpha: 1)
			break
			
		case 2:
			color1 = UIColor(red: 138/255, green: 119/d, blue: 231/d, alpha: 1)
			color2 = UIColor(red: 216/d, green: 120/d, blue: 181/d, alpha: 1)
			break
			
		case 3:
			color1 = UIColor(red: 93/d, green: 127/d, blue: 195/d, alpha: 1)
			color2 = UIColor(red: 74/d, green: 190/d, blue: 236/d, alpha: 1)
			break;
			
		case 4:
			color1 = UIColor(red: 218/d, green: 86/d, blue: 122/d, alpha: 1)
			color2 = UIColor(red: 250/d, green: 213/d, blue: 141/d, alpha: 1)
			break
			
		case 5:
			color1 = UIColor(red: 60/d, green: 216/d, blue: 139/d, alpha: 1)
			color2 = UIColor(red: 39/d, green: 207/d, blue: 200/d, alpha: 1)
			break
			
		case 6:
			color1 = UIColor(red: 157/d, green: 184/d, blue: 199/d, alpha: 1)
			color2 = UIColor(red: 110/d, green: 143/d, blue: 160/d, alpha: 1)
			break
			
		default:
			break
		}
		
		return arc4random_uniform(2) == 0 ? (color1, color2) : (color2, color1)
	}
	
    class func stopAnimating() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
	
    class func setMessage(message: String) -> Void {
        NVActivityIndicatorPresenter.sharedInstance.setMessage(message)
    }
	
}
