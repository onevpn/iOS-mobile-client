import Foundation
import NetworkExtension
import Alamofire

let kVpnStatusChangedNotificationName = "vpn_status_changed_notification_name"

public enum ReachabilityStatus {
    case notReachable
    case securedCell
    case unsecuredCell
    case securedWifi
    case unsecuredWifi
    case securedTrustedWifi
    case unsecuredTrustedWifi
}

public enum VpnStatus {
    case off
    case processing
    case on
}

class Network {
    
    static let shared = Network()
    
    private let manager: NEVPNManager
    
    init() {
        
        self.manager = NEVPNManager.shared()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.vpnStatusChanged), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reachabilityStatus() -> ReachabilityStatus {
        
        let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
        
        if let status = reachabilityManager?.networkReachabilityStatus {
            
            let connectionSecuredWithVPN = NEVPNManager.shared().connection.status == NEVPNStatus.connected
            var connectedToTrustedWiFi = false
            if let ssid = Settings.currentWiFiSSID() {
                connectedToTrustedWiFi = Settings.shared.trustedSSIDs.contains(ssid)
            }
            
            switch status {
            case .reachable(.wwan):
                if connectionSecuredWithVPN {
                    return ReachabilityStatus.securedCell
                } else {
                    return ReachabilityStatus.unsecuredCell
                }
                
            case .reachable(.ethernetOrWiFi):
                if connectionSecuredWithVPN {
                    return connectedToTrustedWiFi ? ReachabilityStatus.securedTrustedWifi : ReachabilityStatus.securedWifi
                } else {
                    return connectedToTrustedWiFi ? ReachabilityStatus.unsecuredTrustedWifi : ReachabilityStatus.unsecuredWifi
                }
                
            default:
                return ReachabilityStatus.notReachable
            }
        }
        
        return ReachabilityStatus.notReachable
        
    }
    
    func onDemandRules() -> [NEOnDemandRule]? {
        
        var rules = [NEOnDemandRule]()
        
        let trustedSSIDs = Settings.shared.trustedSSIDs
        if trustedSSIDs.count > 0 {
            let trustedWifiRule = NEOnDemandRuleIgnore()
            trustedWifiRule.ssidMatch = trustedSSIDs
            rules.append(trustedWifiRule)
        }
        
        if Settings.shared.autoSecureEnabled {
            let autosecureRule = NEOnDemandRuleConnect()
            let type = Settings.shared.trustCellNetwork ? NEOnDemandRuleInterfaceType.wiFi : NEOnDemandRuleInterfaceType.any
            autosecureRule.interfaceTypeMatch = type
            rules.append(autosecureRule)
        }
        
        return rules.count > 0 ? rules : nil
        
    }
    
    func vpnStatus() -> VpnStatus {
        
        let status = self.manager.connection.status
        
        var convertedStatus = VpnStatus.processing
        
        switch status {
            
            case NEVPNStatus.invalid:
                convertedStatus = .off
                break;
                
            case NEVPNStatus.disconnected:
                convertedStatus = .off
                break;
                
            case NEVPNStatus.connected:
                convertedStatus = .on
                break;
                
            default:
                break
        }
        
        return convertedStatus
    }
    
    @objc fileprivate func vpnStatusChanged() -> Void {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kVpnStatusChangedNotificationName), object: nil)
        
    }
    
    func connectVPN() -> Bool {
        do {
            try self.manager.connection.startVPNTunnel()
        } catch {
            return false
        }
        return true
    }
    
    func disconnectVPN() -> Void {
        self.manager.connection.stopVPNTunnel()
    }
    
    func extractServerFromConfig(callback: @escaping (Server?) -> Void) -> Void {
        
        var server: Server? = nil
        
        self.manager.loadFromPreferences { (error) in
            if (error == nil) {
                if let currentProtocol = self.manager.protocolConfiguration {
                    
                    Settings.shared.autoSecureEnabled = self.manager.isOnDemandEnabled
                    
                    server = Server(host: currentProtocol.serverAddress!, name: (currentProtocol as! NEVPNProtocolIPSec).remoteIdentifier!)
                    
                }
            }
            callback(server)
        }
    }
    
    func updateVpnConfig(server: Server, callback: @escaping () -> Void) -> Void {
        
        let passwordRef = Account.shared.passwordRef()
        let secretRef = Account.shared.secretRef()
        
        let username = Account.shared.username
        
        let manager = NEVPNManager.shared()
        manager.loadFromPreferences { (error) in
            if (error != nil)
            {
                print("Error: ", error.debugDescription)
                callback()
            }
            else
            {
                let prtcl = NEVPNProtocolIPSec()
                prtcl.username = username
                prtcl.passwordReference = passwordRef
                prtcl.serverAddress = server.host
                prtcl.remoteIdentifier = server.name
                prtcl.authenticationMethod = NEVPNIKEAuthenticationMethod.sharedSecret
                prtcl.sharedSecretReference = secretRef
                prtcl.useExtendedAuthentication = true
                prtcl.disconnectOnSleep = false
                
                manager.isEnabled = true
                manager.protocolConfiguration = prtcl
                manager.isOnDemandEnabled = Settings.shared.autoSecureEnabled
                manager.onDemandRules = Network.shared.onDemandRules()
                manager.localizedDescription = "OneVPN Configuration"
                
                manager.saveToPreferences(completionHandler: { (error) in
                    if (error != nil)
                    {
                        print("Error: ", error.debugDescription)
                    }
                    callback()
                })
            }
        }
    }
    
}
