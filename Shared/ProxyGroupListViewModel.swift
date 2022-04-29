import Foundation
import Yams
import SwiftUI

struct RawProxy: Decodable {
    let name: String
    let type: String
}

struct RawProxyGroup: Decodable {
    let name: String
    let type: String
    let proxies: [String]
}

struct RawConfig: Decodable {
    let proxies: [RawProxy]
    let groups: [RawProxyGroup]
    enum CodingKeys: String, CodingKey {
        case proxies    = "proxies"
        case groups     = "proxy-groups"
    }
}

struct Provider: Decodable {
    
    struct DelayHistory: Decodable {
        let time: String
        let delay: UInt16
    }
    
    struct Proxy: Decodable {
        let name: String
        let type: String
        let history: [DelayHistory]
    }
    
    let name: String
    let type: String
    let vehicleType: String
    let proxies: [Proxy]
}

enum Delay {
    
    case timeout
    case high(UInt16)
    case medium(UInt16)
    case low(UInt16)
    
    init(value: UInt16) {
        if value == 0 {
            self = .timeout
        } else if value <= 200 {
            self = .low(value)
        } else if value <= 600 {
            self = .medium(value)
        } else {
            self = .high(value)
        }
    }
    
    var displayString: String {
        switch self {
        case .timeout:
            return "超时"
        case .high(let v):
            return "\(v)ms"
        case .medium(let v):
            return "\(v)ms"
        case .low(let v):
            return "\(v)ms"
        }
    }
    
    var displayColor: Color {
        switch self {
        case .timeout, .high:
            return .red
        case .medium:
            return .yellow
        case .low:
            return .green
        }
    }
}

class ProxyGroupViewModel: ObservableObject {
    
    @Published var selectedProxy: String
    @Published var delayMapping: [String: Delay] = [:]
    
    let group: RawProxyGroup
    
    init(group: RawProxyGroup, selectedProxy proxy: String) {
        self.group = group
        self.selectedProxy = proxy
    }
    
    var isSelectable: Bool {
        self.group.type.uppercased() == "SELECT"
    }
    
    func loadProvider() async {
        repeat {
            do {
                guard let controller = VPNManager.shared.controller else {
                    break
                }
                guard let data = try await controller.execute(command: .provider(group.name == "GLOBAL" ? "default" : group.name)) else {
                    break
                }
                let provider = try JSONDecoder().decode(Provider.self, from: data)
                await MainActor.run {
                    self.delayMapping = provider.proxies.reduce(into: [String: Delay]()) { r, n in
                        guard let last = n.history.last else {
                            return
                        }
                        r[n.name] = Delay(value: last.delay)
                    }
                }
                return
            } catch {
                break
            }
        } while false
        await MainActor.run {
            self.delayMapping = [:]
        }
    }
}

class ProxyGroupListViewModel: ObservableObject {
    
    @Published private var mapping: [String: String] = [:]
    @Published var globalGroupViewModels: [ProxyGroupViewModel] = []
    @Published var groupViewModels: [ProxyGroupViewModel] = []
    
    private var storeKey: String = ""
    
    init() {}
    
    func update(uuidString: String) {
        let key = "\(uuidString)-PatchGroup"
        guard key != storeKey else {
            return
        }
        self.storeKey = key
        let raw: RawConfig
        do {
            raw = try YAMLDecoder().decode(
                from: try Data(
                    contentsOf: Clash.homeDirectoryURL.appendingPathComponent("\(uuidString)/config.yaml")
                )
            )
        } catch {
            raw = RawConfig(proxies: [], groups: [])
        }
        let temp = UserDefaults.shared.dictionary(forKey: self.storeKey) as? [String: String] ?? [:]
        self.groupViewModels = raw.groups.map { group in
            ProxyGroupViewModel(group: group, selectedProxy: temp[group.name] ?? group.proxies.first ?? "")
        }
        self.globalGroupViewModels = {
            var proxies: [String] = []
            proxies.append("DIRECT")
            proxies.append("REJECT")
            proxies.append(contentsOf: raw.proxies.map({ $0.name }))
            proxies.append(contentsOf: self.groupViewModels.map({ $0.group.name }))
            let group = RawProxyGroup(name: "GLOBAL", type: "select", proxies: proxies)
            let viewModel = ProxyGroupViewModel(
                group: group,
                selectedProxy: temp[group.name] ?? group.proxies.first ?? ""
            )
            return [viewModel]
        }()
        self.mapping = temp
    }
    
    func setSelected(proxy: String, groupViewModel: ProxyGroupViewModel) {
        self.mapping[groupViewModel.group.name] = proxy
        UserDefaults.shared.setValue(self.mapping, forKey: self.storeKey)
        Task(priority: .high) {
            guard let controller = VPNManager.shared.controller else {
                return
            }
            do {
                try await controller.execute(command: .setSelectGroup)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
