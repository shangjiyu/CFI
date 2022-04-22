import Foundation
import os
import ClashKit
import T2SKit

fileprivate extension Logger {
    static let tunnel = Logger(subsystem: Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String, category: "Clash")
}

extension PacketTunnelProvider: ClashTrafficReceiverProtocol, ClashNativeLoggerProtocol {
    
    func setupClash() throws {
        let config = """
        mixed-port: 8080
        mode: \(UserDefaults.shared.string(forKey: Clash.tunnelMode) ?? Clash.TunnelMode.rule.rawValue)
        log-level: \(UserDefaults.shared.string(forKey: Clash.logLevel) ?? Clash.LogLevel.silent.rawValue)
        """
        var error: NSError? = nil
        ClashSetup(Clash.homeDirectoryURL.path, config, &error)
        if let error = error {
            throw error
        }
        ClashSetNativeLogger(self)
        ClashSetTrafficReceiver(self)
        DispatchQueue.global(qos: .userInteractive).async {
            guard let fd = self.tunnelFileDescriptor else {
                return
            }
            Tun2Socks.start(fd: fd, host: "127.0.0.1", port: 8080)
        }
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
              let mapping = UserDefaults.shared.dictionary(forKey: "\(id)-SelectGroup") as? [String: String], !mapping.isEmpty else {
            return
        }
        do {
            ClashPatchSelectGroup(try JSONEncoder().encode(mapping))
        } catch {
            debugPrint(error.localizedDescription)
        }
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
    
    private var tunnelFileDescriptor: Int32? {
        var buf = Array<CChar>(repeating: 0, count: Int(IFNAMSIZ))
        return (1...1024).first {
            var len = socklen_t(buf.count)
            return getsockopt($0, 2, 2, &buf, &len) == 0 && String(cString: buf).hasPrefix("utun")
        }
    }
}
