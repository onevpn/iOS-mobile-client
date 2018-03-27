import Foundation
import SystemConfiguration.CaptiveNetwork
import SwiftKeychainWrapper

let kSettingsUpdatedNotificationName = "settings_updated_notification_name"

fileprivate struct Keys {
    static let autoSecure = "nsud_autosecure_key"
    static let trustCell = "nsud_trust_cell_key"
    static let trustedWifiList = "keychain_trusted_wifi"
    static let skipLoginGuides = "nsud_skip_after_login_screens"
    static let lastServerImage = "nsud_last_server_image"
}

class Settings {

    static let shared = Settings()
    
    class func currentWiFiSSID() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    
    class func startTrustingSSID(ssid: String) -> Bool {
        var trustedList = self.shared.trustedSSIDs
        if trustedList.contains(ssid) == false {
            trustedList.append(ssid)
            self.shared.trustedSSIDs = trustedList
            self.shared.synchronizeAndNotify()
            return true
        }
        return false
    }
    
    class func stopTrustingSSID(ssid: String) -> Bool {
        var trustedList = self.shared.trustedSSIDs
        if let index = trustedList.index(of: ssid) {
            trustedList.remove(at: index)
            self.shared.trustedSSIDs = trustedList
            self.shared.synchronizeAndNotify()
            return true
        }
        return false
    }
    
    fileprivate func synchronizeAndNotify() {
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kSettingsUpdatedNotificationName), object: nil)
    }
    
    var autoSecureEnabled: Bool
    {
        get {
            return UserDefaults.standard.bool(forKey: Keys.autoSecure)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.autoSecure)
            self.synchronizeAndNotify()
        }
    }
    
    var trustCellNetwork: Bool
    {
        get {
            return UserDefaults.standard.bool(forKey: Keys.trustCell)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.trustCell)
            self.synchronizeAndNotify()
        }
    }
    
    var trustedSSIDs: [String]
    {
        get {
            if let ssids = KeychainWrapper.standard.data(forKey: Keys.trustedWifiList) {
                let list = NSKeyedUnarchiver.unarchiveObject(with: ssids) as! [String]
                return list
            }
            return []
        }
        set {
            let ssids = NSKeyedArchiver.archivedData(withRootObject: newValue)
            KeychainWrapper.standard.set(ssids, forKey: Keys.trustedWifiList)
        }
    }
    
    var skipLoginGuides: Bool
    {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.skipLoginGuides)
        }
        get {
            return UserDefaults.standard.bool(forKey: Keys.skipLoginGuides)
        }
    }
    
    var lastServerImage: String?
    {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.lastServerImage)
        }
        get {
            return UserDefaults.standard.string(forKey: Keys.lastServerImage)
        }
    }
    
}
