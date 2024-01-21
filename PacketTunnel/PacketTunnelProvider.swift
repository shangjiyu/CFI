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
            let settings = NEIPv4Settings(addresses: ["198.18.0.1"], subnetMasks: ["255.255.0.0"])
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
            case .setTunnelMode:
                ClashSetTunnelMode(tunnelMode.rawValue)
            case .setLogLevel:
                ClashSetLogLevel(logLevel.rawValue)
            case .setSelectGroup:
                self.setSelectGroup()
            case .mergedProxyData:
                return ClashMergedProxyData()
            case .patchData:
                return ClashPatchData()
            case .healthCheck(let name, let url, let timeout):
                ClashHealthCheck(name, url.absoluteString, timeout)
            }
            return nil
        } catch {
            return error.localizedDescription.data(using: .utf8)
        }
    }
}
