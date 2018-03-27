import Foundation
import SwiftKeychainWrapper

fileprivate struct Keys {
    static let token = "keychain_token_key"
    static let username = "keychain_username_key"
    static let password = "keychain_password_key"
    static let sharedSecret = "keychain_ipsec_secret"
    static let trafficIn = "nsud_traffic_in_key"
    static let trafficLimit = "nsud_traffic_limit_key"
    static let trafficOut = "nsud_traffic_out_key"
    static let trafficTotal = "nsud_traffic_total_key"
    static let daysPaid = "nsud_days_paid_key"
    static let planExpiration = "nsud_plan_expiration_key"
    static let planName = "nsud_plan_name_key"
    static let payLink = "nsud_pay_link_key"
    static let isLoaded = "nsud_data_loaded_flag_key"
    static let unlockPassword = "keychain_lock_password_key"
    static let isPasswordEnabled = "nsud_password_lock_enabled"
    static let isTouchIdEnabled = "nsud_touch_id_auth_enabled"
}

class Account {

    static let shared = Account()
    
    fileprivate func synchronize() {
        UserDefaults.standard.synchronize()
    }
    
    var token: String
    {
        set {
            KeychainWrapper.standard.set(newValue, forKey: Keys.token)
        }
        get {
            return KeychainWrapper.standard.string(forKey: Keys.token) ?? ""
        }
    }
    
    var username: String
    {
        set {
            KeychainWrapper.standard.set(newValue, forKey: Keys.username)
        }
        get {
            return KeychainWrapper.standard.string(forKey: Keys.username) ?? ""
        }
    }
    
    var password: String
    {
        set {
            KeychainWrapper.standard.set(newValue, forKey: Keys.password)
        }
        get {
            return KeychainWrapper.standard.string(forKey: Keys.password) ?? ""
        }
    }
    
    func passwordRef() -> Data? {
        return KeychainWrapper.standard.dataRef(forKey: Keys.password)
    }
    
    var ipsec_secret: String
    {
        set {
            KeychainWrapper.standard.set(newValue, forKey: Keys.sharedSecret)
        }
        get {
            return KeychainWrapper.standard.string(forKey: Keys.sharedSecret) ?? ""
        }
    }
    
    func secretRef() -> Data? {
        return KeychainWrapper.standard.dataRef(forKey: Keys.sharedSecret)
    }
    
    var traffic_in: Double
    {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.trafficIn)
        }
        get {
            return UserDefaults.standard.double(forKey: Keys.trafficIn)
        }
    }
    
    var traffic_limit: Int32
    {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.trafficLimit)
        }
        get {
            return Int32(UserDefaults.standard.integer(forKey: Keys.trafficLimit))
        }
    }
    
    var traffic_out: Double
    {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.trafficOut)
        }
        get {
            return UserDefaults.standard.double(forKey: Keys.trafficOut)
        }
    }
    
    var traffic_total: Double
    {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.trafficTotal)
        }
        get {
            return UserDefaults.standard.double(forKey: Keys.trafficTotal)
        }
    }
    
    var days_paid: Int
    {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.daysPaid)
        }
        get {
            return UserDefaults.standard.integer(forKey: Keys.daysPaid)
        }
    }
    
    var plan_expires: Int
    {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.planExpiration)
        }
        get {
            return UserDefaults.standard.integer(forKey: Keys.planExpiration)
        }
    }
    
    var plan_name: String
    {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.planName)
        }
        get {
            return UserDefaults.standard.string(forKey: Keys.planName) ?? ""
        }
    }
    
    var pay_link: String
    {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.payLink)
        }
        get {
            return UserDefaults.standard.string(forKey: Keys.payLink) ?? ""
        }
    }
    
    var isLoaded: Bool
    {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.isLoaded)
            self.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: Keys.isLoaded)
        }
    }
    
    var unlockPassword: String
    {
        set {
            KeychainWrapper.standard.set(newValue, forKey: Keys.unlockPassword)
        }
        get {
            return KeychainWrapper.standard.string(forKey: Keys.unlockPassword) ?? ""
        }
    }
    
    var isPasswordEnabled: Bool
    {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.isPasswordEnabled)
            self.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: Keys.isPasswordEnabled)
        }
    }
    
    var isTouchIdEnabled: Bool
    {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.isTouchIdEnabled)
            self.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: Keys.isTouchIdEnabled)
        }
    }
    
    func clear() -> Void {
        self.token = ""
        self.username = ""
        self.password = ""
        self.ipsec_secret = ""
        self.traffic_in = 0
        self.traffic_out = 0
        self.traffic_limit = 0
        self.traffic_total = 0
        self.days_paid = 0
        self.plan_name = ""
        self.plan_expires = 0
        self.pay_link = ""
        self.unlockPassword = ""
        self.isLoaded = false
        self.isPasswordEnabled = false
        self.isTouchIdEnabled = false
    }
}
