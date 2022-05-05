import Foundation

struct MergedProxyData: Decodable {
    
    struct Proxy: Decodable {
        let name: String
        let type: String
        let now: String?
        let all: [String]?
        let history: [DelayHistory]
    }
    
    struct Provider: Decodable {
        let proxies: [Proxy]
        let name: String
        let type: String
        let vehicleType: String
    }
    
    let proxies: [String: Proxy]
    let providers: [String: Provider]
}
