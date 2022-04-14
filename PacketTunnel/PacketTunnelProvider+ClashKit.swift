import Foundation
import os
import ClashKit

fileprivate extension Logger {
    static let tunnel = Logger(subsystem: Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String, category: "Clash")
}

extension PacketTunnelProvider: ClashPacketFlowProtocol, ClashTrafficReceiverProtocol, ClashNativeLoggerProtocol {
    
    func setupClash() throws {
        let config = """
        mixed-port: 8080
        mode: \(UserDefaults.shared.string(forKey: Clash.tunnelMode) ?? Clash.TunnelMode.rule.rawValue)
        log-level: \(UserDefaults.shared.string(forKey: Clash.logLevel) ?? Clash.LogLevel.silent.rawValue)
        """
        var error: NSError? = nil
        ClashSetup(self, Clash.homeDirectoryURL.path, config, &error)
        if let error = error {
            throw error
        }
        ClashSetNativeLogger(self)
        ClashSetTrafficReceiver(self)
    }
    
    func setConfig() throws {
        var error: NSError? = nil
        ClashSetConfig(UserDefaults.shared.string(forKey: Clash.currentConfigUUID), &error)
        if let error = error {
            throw error
        }
        self.setSelectGroup()
    }
    
    func setSelectGroup() {
        guard let id = UserDefaults.shared.string(forKey: Clash.currentConfigUUID), !id.isEmpty,
              let mapping = UserDefaults.shared.dictionary(forKey: id) as? [String: String], !mapping.isEmpty else {
            return
        }
        do {
            ClashPatchSelectGroup(try JSONEncoder().encode(mapping))
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func readPackets() {
        self.packetFlow.readPackets { packets, _ in
            packets.forEach(ClashReadPacket(_:))
            self.readPackets()
        }
    }
    
    func writePacket(_ packet: Data?) {
        guard let packet = packet else {
            return
        }
        self.packetFlow.writePackets([packet], withProtocols: [AF_INET as NSNumber])
    }
    
    func receiveTraffic(_ up: Int64, down: Int64) {
        UserDefaults.shared.set(Double(up), forKey: Clash.Traffic.up.rawValue)
        UserDefaults.shared.set(Double(down), forKey: Clash.Traffic.down.rawValue)
    }
    
    func log(_ level: String?, payload: String?) {
        guard let level = level.flatMap(Clash.LogLevel.init(rawValue:)),
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
