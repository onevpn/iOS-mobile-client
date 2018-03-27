import Foundation

struct AnalyticsActions {
	static let signUp = "Sign Up"
	static let signIn = "Sign In"
	static let signOut = "Sign Out"
	static let vpnOn = "VPN ON"
	static let vpnOff = "VPN OFF"
	static let selectServer = "Select server"
	static let upgradeToPremium = "Upgrade"
	static let unprotectedWifi = "Unprotected Wifi"
	static let autoconnectOn = "Autoconnect On"
	static let autoconnectOff = "Autoconnect Off"
	static let wifiWhiteList = "Add Wifi To Whitelist"
}

class Analytics {

	class func sendAction(action: String) {
		guard let tracker = GAI.sharedInstance().defaultTracker else { return }
		guard let builder = GAIDictionaryBuilder.createEvent(withCategory: "Action", action: action, label: "", value: 1) else { return }
		tracker.send(builder.build() as [NSObject : AnyObject])
	}
	
}
