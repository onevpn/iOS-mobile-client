import Foundation
import Alamofire
import ObjectMapper
import SwiftKeychainWrapper
import CryptoSwift

class API: NSObject {
    
    fileprivate static let salt = "Some_Salt_We_Can_Not_Tell_You_Hehe"
    fileprivate static let host = "https://onevpn.co/members/mobile/api/"
    fileprivate static let ipCheckHost = "https://api.ipify.org?format=json"
    
    static let shared = API()
    
    var cachedServers = [Server]()
    
    fileprivate func errorMessage(jsonDictionary: Dictionary<String, Any>) -> String? {
        
        if let message = jsonDictionary["message"] {
            
            let messageObj = message as! [String: Any]
            
            if let text = messageObj["value"] {
                
                let value = text as! String
                
                if value == "Success" {
                    return nil
                } else {
                    return value
                }
            }
            
            return nil
        }
        
        return nil
    }
    
    func generateToken(password: String) -> String {
        return (password + API.salt).md5()
    }
    
    func register(email: String, completion: @escaping (Bool) -> Void) -> Void {
        
        Activity.startAnimating(message: "Signing up".localized())
        
        let key = email + API.salt
        
        request(URL(string:API.host)!, method: .post, parameters: ["email":email, "key":key.md5(),"ios":true, "signup":true], encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            Activity.stopAnimating()
            
            if let json = response.result.value {
                
                let result = json as! Dictionary<String, Any>
                
                if let error = self.errorMessage(jsonDictionary: result) {
                
                    Alert().showError("Error".localized(), subTitle: error)
                    completion(false)
                    
                } else {
					
					Alert().showSuccess("Success".localized(), subTitle: "Email was sent. Please check it in 30 seconds. If no message recieved, check again in 1 minute and check Spam folder.".localized())
                    completion(true)
                }
                
            } else {
                
                Alert().showError("Unexpected error".localized(), subTitle: "Check internet connection".localized())
                completion(false)
            
            }
        }
    }
    
    func getDataFromAPI(completion: @escaping ([Server]?) -> Void) {
        
        Activity.startAnimating(message: "Loading".localized())
        
        let dataRequest = request(URL(string:API.host)!, method: .post, parameters: ["login":Account.shared.username, "pass":Account.shared.token, "mode":"auth", "ios":true], encoding: URLEncoding.default, headers: nil)
        
        dataRequest.responseJSON { (response) in
            
            let json = response.result.value
            
            if json != nil {
                
                let result = json as! Dictionary<String, Any>
                print(result)
                
                if let message = self.errorMessage(jsonDictionary: result) {
                    Alert().showError("Error".localized(), subTitle: message)
                    Activity.stopAnimating()
                    completion(nil)
                    return
                }
                
                let serversList = result["servers"] as! [[String : Any]]
                let servers = Mapper<Server>().mapArray(JSONArray: serversList)
                
                let auth_data = result["auth"] as! [String : Any]
                let bandwidth = result["bandwidth"] as! [String : Any]
                let plan = result["plan"] as! [String : Any]
        
                let pay_link = result["pay"] as! [String : Any]
                
                let username = auth_data["login"] as! String
                let password = auth_data["password"] as! String
                let traffic_in = bandwidth["in"] as? Double
                let traffic_out = bandwidth["out"] as? Double
                let traffic_limit = bandwidth["limit"] as? Int32
                let traffic_total = bandwidth["total"] as? Double
                let plan_name = plan["plan_name"] as? String

                let days_paid = plan["days_paid"] as? String
                let plan_expired = plan["plan_expired"] as? Int
                let pay_url = pay_link["url"] as? String
                
                let account = Account.shared
                account.username = username
                account.password = password
                account.traffic_in = traffic_in ?? 0
                account.traffic_out = traffic_out ?? 0
                account.traffic_limit = traffic_limit ?? 0
                account.traffic_total = traffic_total ?? 0
                account.plan_name = plan_name ?? ""
                account.days_paid = Int(days_paid ?? "0") ?? 0
                account.plan_expires = plan_expired ?? 0
                account.pay_link = pay_url ?? ""
                account.isLoaded = true
                
                let ipsec = result["ipsec"] as! [String : Any]
                let ipsec_secret = ipsec["ipsec_secret"] as! String

                account.ipsec_secret = ipsec_secret
                
                completion(servers)
            }
            else
            {
                completion(nil)
            }
            Activity.stopAnimating()
        }
    }
    
    func getExternalIP(completion: @escaping (String?) -> Void) {
        
        request(URL(string:API.ipCheckHost)!).responseJSON { (response) in
            
            let json = response.result.value
			
            if json != nil {
                let ip_data = json as! Dictionary<String, Any>
                let ip = ip_data["ip"] as? String
                completion(ip)
            } else {
                completion(nil)
            }
        }
    }
    
    func recoverPassword(email: String, completion: @escaping (Bool) -> Void) -> Void {
        
        Activity.startAnimating(message: "Loading".localized())
        
        request(URL(string:API.host)!, method: .post, parameters: ["userid":email, "reminder":true,"ios":true], encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            Activity.stopAnimating()
            
            if let json = response.result.value {
                
                let result = json as! Dictionary<String, Any>
                
                if let error = self.errorMessage(jsonDictionary: result) {
                    
                    Alert().showError("Error".localized(), subTitle: error)
                    completion(false)
                    
                } else {
                    
                    Alert().showSuccess("Success".localized(), subTitle: "Email was sent. Please check it in 30 seconds. If no message recieved, check again in 1 minute and check Spam folder.".localized())
                    completion(true)
                }
                
            } else {
                
                Alert().showError("Unexpected error".localized(), subTitle: "Check internet connection".localized())
                completion(false)
                
            }
        }
    }

}
