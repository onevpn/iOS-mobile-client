import UIKit
import ObjectMapper

class Server: Mappable {
    
    var host: String?
    var flag: String?
    var distance: Int?
    var name: String?
    var country: String?
    var ping: Int?
    var emoji: String?
    
    init(host: String, name: String) {
        self.host = host
        self.name = name
    }
    
    required init?(map: Map) {
        if map.JSON["DNS"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        host <- map["DNS"]
        flag <- map["Flag"]
        distance <- map["KM"]
        name <- map["Name"]
        country <- map["Country"]
        emoji <- map["emoji"]
    }
}
