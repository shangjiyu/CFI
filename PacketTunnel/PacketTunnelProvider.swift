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
        do {
            let command = try JSONDecoder().decode(Clash.Command.self, from: messageData)
            switch command {
            case .setConfig:
                try self.setConfig()
                return nil
            case .setTunnelMode:
                ClashSetTunnelMode(UserDefaults.shared.string(forKey: Clash.tunnelMode))
                return nil
            case .setLogLevel:
                ClashSetLogLevel(UserDefaults.shared.string(forKey: Clash.logLevel))
                return nil
            case .setSelectGroup:
                self.setSelectGroup()
                return nil
            case .fetchProxyDelay(let name, let url, let timeout):
                let res = await URLTest.fetchProxyDelay(name: name, url: url, timeout: timeout)
                return "\(res)".data(using: .utf8)
            }
        } catch {
            return error.localizedDescription.data(using: .utf8)
        }
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
    
    private static func fetchProxyDelay(name: String, url: String, timeout: Int64, completion: @escaping (Int64) -> Void) {
        DispatchQueue.global().async {
            let delay = ClashURLTest(name, url, timeout)
            DispatchQueue.main.async {
                completion(delay)
            }
        }
    }
    
    public static func fetchProxyDelay(name: String, url: String, timeout: Int64) async -> Int64 {
        return await withCheckedContinuation { continuation in
            self.fetchProxyDelay(name: name, url: url, timeout: timeout) { delay in
                continuation.resume(returning: delay)
            }
        }
    }
}
