import Foundation
import NetworkExtension
import os
import ClashKit

class PacketTunnelProvider: NEPacketTunnelProvider {
        
    override func startTunnel(options: [String : NSObject]? = nil) async throws {
        try self.setupClash()
        try self.setCurrentConfig()
        self.patchSelectGroup()
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "240.240.240.240")
        settings.mtu = 1500
        settings.ipv4Settings = {
            let settings = NEIPv4Settings(addresses: ["240.0.0.1"], subnetMasks: ["255.255.255.0"])
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
            let settings = NEDNSSettings(servers: ["127.0.0.1"])
            return settings
        }()
        try await self.setTunnelNetworkSettings(settings)
        DispatchQueue.main.async(execute: self.readPackets)
    }
    
    private func readPackets() {
        self.packetFlow.readPackets { packets, _ in
            packets.forEach(ClashReadPacket(_:))
            self.readPackets()
        }
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
        guard let command = messageData.first.flatMap(ClashCommand.init(rawValue:)) else {
            return nil
        }
        switch command {
        case .setCurrentConfig:
            do {
                try self.setCurrentConfig()
            } catch {
                return error.localizedDescription.data(using: .utf8)
            }
        case .setTunnelMode:
            ClashSetTunnelMode(UserDefaults.shared.string(forKey: Constant.tunnelMode))
        case .setLogLevel:
            ClashSetLogLevel(UserDefaults.shared.string(forKey: Constant.logLevel))
        case .patchSelectGroup:
            self.patchSelectGroup()
        }
        return nil
    }
}

fileprivate extension Logger {
    static let tunnel = Logger(subsystem: "com.Arror.Clash.PacketTunnel", category: "Clash")
}

extension PacketTunnelProvider: ClashPacketFlowProtocol, ClashTrafficReceiverProtocol, ClashRealTimeLoggerProtocol {
    
    func setupClash() throws {
        let config = """
        mixed-port: 8080
        mode: \(UserDefaults.shared.string(forKey: Constant.tunnelMode) ?? ClashTunnelMode.rule.rawValue)
        log-level: \(UserDefaults.shared.string(forKey: Constant.logLevel) ?? ClashLogLevel.silent.rawValue)
        dns:
          enable: true
          ipv6: false
          listen: 0.0.0.0:53
          enhanced-mode: redir-host
          use-hosts: false
          nameserver:
            - 114.114.114.114
          fallback:
            - 8.8.8.8
            - 1.1.1.1
            - tls://8.8.8.8:853
            - tls://1.1.1.1:853
            - https://dns.google/dns-query
            - https://cloudflare-dns.com/dns-query
          fallback-filter:
            geoip: true
            ipcidr:
              - 240.0.0.0/4
        """
        var error: NSError? = nil
        ClashSetup(self, Constant.homeDirectoryURL.path, config, &error)
        if let error = error {
            throw error
        }
        ClashSetRealTimeLogger(self)
        ClashSetTrafficReceiver(self)
    }
    
    func setCurrentConfig() throws {
        var error: NSError? = nil
        ClashSetConfig(UserDefaults.shared.string(forKey: Constant.currentConfigUUID), &error)
        guard let error = error else {
            return
        }
        throw error
    }
    
    func patchSelectGroup() {
        guard let id = UserDefaults.shared.string(forKey: Constant.currentConfigUUID), !id.isEmpty,
              let mapping = UserDefaults.shared.dictionary(forKey: id) as? [String: String], !mapping.isEmpty else {
            return
        }
        do {
            ClashPatchSelectGroup(try JSONEncoder().encode(mapping))
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func writePacket(_ packet: Data?) {
        guard let packet = packet else {
            return
        }
        self.packetFlow.writePackets([packet], withProtocols: [AF_INET as NSNumber])
    }
    
    func receiveTraffic(_ up: Int64, down: Int64) {
        UserDefaults.shared.set(Double(up), forKey: ClashTraffic.up.rawValue)
        UserDefaults.shared.set(Double(down), forKey: ClashTraffic.down.rawValue)
    }
    
    func log(_ level: String?, payload: String?) {
        guard let level = level.flatMap(ClashLogLevel.init(rawValue:)),
              let payload = payload, !payload.isEmpty else {
            return
        }
        switch level {
        case .silent:
            break
        case .info, .debug:
            Logger.tunnel.notice("\(payload, privacy: .public)")
        case .warning:
            Logger.tunnel.warning("\(payload, privacy: .public)")
        case .error:
            Logger.tunnel.critical("\(payload, privacy: .public)")
        }
    }
}
