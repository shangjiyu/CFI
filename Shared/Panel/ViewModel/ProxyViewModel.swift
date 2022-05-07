import Foundation
import SwiftUI

class ProxyViewModel: ObservableObject {
    
    let name: String
    let type: AdapterType
    let isURLTestEnable: Bool
    @Published var histories: [DelayHistory]
    
    private static let types: Set<AdapterType> = [.shadowsocks, .shadowsocksR, .snell, .socks5, .http, .vmess, .trojan]
    
    init(name: String, type: String, histories: [DelayHistory]) {
        let reval = AdapterType(type: type)
        self.name = name
        self.type = reval
        self.histories = histories
        self.isURLTestEnable = ProxyViewModel.types.contains(reval)
    }
    
    var delay: String {
        guard let last = histories.last else {
            return ""
        }
        if last.delay == 0 {
            return "超时"
        } else {
            return "\(last.delay)ms"
        }
    }
    
    var delayTextColor: Color {
        guard let last = histories.last else {
            return .clear
        }
        if last.delay == 0 {
            return .secondary
        } else if last.delay <= 300 {
            return .green
        } else if last.delay <= 600 {
            return .yellow
        } else {
            return .red
        }
    }
}
