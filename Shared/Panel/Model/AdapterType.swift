import Foundation

enum AdapterType: String {
    
    case direct         = "Direct"
    case reject         = "Reject"
    
    case shadowsocks    = "Shadowsocks"
    case shadowsocksR   = "ShadowsocksR"
    case snell          = "Snell"
    case socks5         = "Socks5"
    case http           = "Http"
    case vmess          = "Vmess"
    case trojan         = "Trojan"
    
    case relay          = "Relay"
    case selector       = "Selector"
    case fallback       = "Fallback"
    case urlTest        = "URLTest"
    case loadBalance    = "LoadBalance"
    
    case unknown
    
    init(type: String) {
        self = AdapterType(rawValue: type) ?? .unknown
    }
}
