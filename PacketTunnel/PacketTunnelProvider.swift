import Foundation
import NetworkExtension
import ClashKit

class PacketTunnelProvider: NEPacketTunnelProvider {
        
    override func startTunnel(options: [String : NSObject]? = nil) async throws {
        try self.setupClash()
        try self.setConfig()
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "254.1.1.1")
        settings.mtu = 1500
        settings.ipv4Settings = {
            let settings = NEIPv4Settings(addresses: ["198.18.0.1"], subnetMasks: ["255.255.255.0"])
            settings.includedRoutes = [NEIPv4Route.default()]
            return settings
        }()
        settings.proxySettings = {
            let settings = NEProxySettings()
            settings.matchDomains = [""]
            settings.excludeSimpleHostnames = true
            settings.httpEnabled = true
            settings.httpServer = NEProxyServer(address: "127.0.0.1", port: 8080)
            settings.httpsEnabled = true
            settings.httpsServer = NEProxyServer(address: "127.0.0.1", port: 8080)
            return settings
        }()
        settings.dnsSettings = {
            let settings = NEDNSSettings(servers: ["114.114.114.114", "8.8.8.8"])
            return settings
        }()
        try await self.setTunnelNetworkSettings(settings)
    }
    
    override func stopTunnel(with reason: NEProviderStopReason) async {
        do {
            try await self.setTunnelNetworkSettings(nil)
        } catch {
            debugPrint(error)
        }
        self.receiveTraffic(0, down: 0)
    }
    
    override func handleAppMessage(_ messageData: Data) async -> Data? {
        guard let name = String(data: messageData, encoding: .utf8) else {
            return nil
        }
        do {
            let res = try await URLTest.fetchProxyDelay(name: name, url: "http://www.gstatic.com/generate_204", timeout: 1000)
            return "\(res)".data(using: .utf8)
        } catch {
            return "超时".data(using: .utf8)
        }
        
//        guard let command = messageData.first.flatMap(Clash.Command.init(rawValue:)) else {
//            return nil
//        }
//        switch command {
//        case .setConfig:
//            do {
//                try self.setConfig()
//            } catch {
//                return error.localizedDescription.data(using: .utf8)
//            }
//        case .setTunnelMode:
//            ClashSetTunnelMode(UserDefaults.shared.string(forKey: Clash.tunnelMode))
//        case .setLogLevel:
//            ClashSetLogLevel(UserDefaults.shared.string(forKey: Clash.logLevel))
//        case .setSelectGroup:
//            self.setSelectGroup()
//        }
//        return nil
    }
    
    private var tunnelFileDescriptor: Int32? {
        var buf = Array<CChar>(repeating: 0, count: Int(IFNAMSIZ))
        return (1...1024).first {
            var len = socklen_t(buf.count)
            return getsockopt($0, 2, 2, &buf, &len) == 0 && String(cString: buf).hasPrefix("utun")
        }
    }
}


enum URLTest {
    
    private static func fetchProxyDelay(name: String, url: String, timeout: Int64, completion: @escaping (Swift.Result<Int64, Error>) -> Void) {
        DispatchQueue.global().async {
            let delay = ClashURLTest(name, url, timeout)
            DispatchQueue.main.async {
                switch delay {
                case 0:
                    completion(.failure(NSError(domain: "Clash.URLTest", code: 1000, userInfo: [NSLocalizedDescriptionKey: "代理不存在"])))
                case -1:
                    completion(.failure(NSError(domain: "Clash.URLTest", code: 1001, userInfo: [NSLocalizedDescriptionKey: "超时"])))
                case -2:
                    completion(.failure(NSError(domain: "Clash.URLTest", code: 1002, userInfo: [NSLocalizedDescriptionKey: "发生位置错误"])))
                default:
                    completion(.success(delay))
                }
            }
        }
    }
    
    public static func fetchProxyDelay(name: String, url: String, timeout: Int64) async throws -> Int64 {
        return try await withCheckedThrowingContinuation { continuation in
            self.fetchProxyDelay(name: name, url: url, timeout: timeout) { result in
                switch result {
                case .success(let delay):
                    continuation.resume(with: .success(delay))
                case .failure(let error):
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }
}
