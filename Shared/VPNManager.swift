import Combine
import NetworkExtension

@MainActor public final class VPNManager: ObservableObject {
    
    private var cancellables: Set<AnyCancellable> = []
        
    @Published public var controller: VPNController?
    
    public static let shared = VPNManager()
    
    private let providerBundleIdentifier: String = {
        let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String
        return "\(identifier).PacketTunnel"
    }()
    
    private init() {
        NotificationCenter.default
            .publisher(for: Notification.Name.NEVPNConfigurationChange, object: nil)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in self.handleVPNConfigurationChangedNotification($0) }
            .store(in: &self.cancellables)
        Task(priority: .high) {
            await self.loadController()
        }
    }
    
    private func handleVPNConfigurationChangedNotification(_ notification: Notification) {
        Task(priority: .high) {
            await self.loadController()
        }
    }
    
    private func loadController() async {
        if let manager = try? await self.loadCurrentTunnelProviderManager() {
            if let controller = self.controller, controller.isEqually(manager: manager) {
                // Nothing
            } else {
                self.controller = VPNController(providerManager: manager)
            }
        } else {
            self.controller = nil
        }
    }
    
    private func loadCurrentTunnelProviderManager() async throws -> NETunnelProviderManager? {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        let first = managers.first { manager in
            guard let configuration = manager.protocolConfiguration as? NETunnelProviderProtocol else {
                return false
            }
            return configuration.providerBundleIdentifier == self.providerBundleIdentifier
        }
        do {
            guard let first = first else {
                return nil
            }
            try await first.loadFromPreferences()
            return first
        } catch {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    public func installVPNConfiguration() async throws {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "Clash"
        manager.protocolConfiguration = {
            let configuration = NETunnelProviderProtocol()
            configuration.providerBundleIdentifier = self.providerBundleIdentifier
            configuration.serverAddress = "Clash"
            configuration.excludeLocalNetworks = true
            return configuration
        }()
        manager.isEnabled = true
        manager.isOnDemandEnabled = true
        try await manager.saveToPreferences()
    }
}

@MainActor public final class VPNController: ObservableObject {
    
    private var cancellables: Set<AnyCancellable> = []
    let providerManager: NETunnelProviderManager
    
    public var connectedDate: Date? {
        self.providerManager.connection.connectedDate
    }
    
    @Published public var connectionStatus: NEVPNStatus
    
    public init(providerManager: NETunnelProviderManager) {
        self.providerManager = providerManager
        self.connectionStatus = providerManager.connection.status
        NotificationCenter.default
            .publisher(for: Notification.Name.NEVPNStatusDidChange, object: self.providerManager.connection)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in self.handleVPNStatusDidChangeNotification($0) }
            .store(in: &self.cancellables)
    }
    
    private func handleVPNStatusDidChangeNotification(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection, connection === self.providerManager.connection else {
            return
        }
        self.connectionStatus = connection.status
    }
    
    public func isEqually(manager: NETunnelProviderManager) -> Bool {
        self.providerManager === manager
    }
    
    public func startVPN() async throws {
        switch self.providerManager.connection.status {
        case .disconnecting, .disconnected:
            break
        case .connecting, .connected, .reasserting, .invalid:
            return
        @unknown default:
            break
        }
        if !self.providerManager.isEnabled {
            self.providerManager.isEnabled = true
            try await self.providerManager.saveToPreferences()
        }
        try self.providerManager.connection.startVPNTunnel()
    }

    public func stopVPN() {
        switch self.providerManager.connection.status {
        case .disconnecting, .disconnected, .invalid:
            return
        case .connecting, .connected, .reasserting:
            break
        @unknown default:
            break
        }
        self.providerManager.connection.stopVPNTunnel()
    }
    
    public func uninstallVPNConfiguration() async throws {
        try await self.providerManager.removeFromPreferences()
    }
    
    @discardableResult
    public func execute(command: Clash.Command) async throws -> Data? {
        return try await self.providerManager.sendProviderMessage(data: try JSONEncoder().encode(command))
    }
}

extension NETunnelProviderManager {
    
    @discardableResult
    func sendProviderMessage(data: Data) async throws -> Data? {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try (self.connection as! NETunnelProviderSession).sendProviderMessage(data) {
                    continuation.resume(with: .success($0))
                }
            } catch {
                continuation.resume(with: .failure(error))
            }
        }
    }
}
