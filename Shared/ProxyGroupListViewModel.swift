import Foundation
import Yams

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

class ProxyGroupViewModel: ObservableObject {
    
#if os(macOS)
    @Published fileprivate(set) var selectedProxy: String
#else
    @Published var selectedProxy: String
#endif
    
    @Published var delayMapping: [String: UInt16] = [:]
    
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
                guard let controller = await VPNManager.shared.controller else {
                    break
                }
                guard let data = try await controller.execute(command: .provider(group.name)) else {
                    break
                }
                let provider = try JSONDecoder().decode(Provider.self, from: data)
                self.delayMapping = provider.proxies.reduce(into: [String: UInt16]()) { r, n in
                    guard let last = n.history.last else {
                        return
                    }
                    r[n.name] = last.delay
                }
                return
            } catch {
                break
            }
        } while false
        self.delayMapping = [:]
    }
}

class ProxyGroupListViewModel: ObservableObject {
    
    @Published private var mapping: [String: String] = [:]
    @Published var groupViewModels: [ProxyGroupViewModel] = []
#if os(macOS)
    @Published var selectedGroupViewModel: ProxyGroupViewModel?
#endif
    
    private var storeKey: String = ""
    
    init() {}
    
    func update(uuidString: String) {
        guard uuidString != storeKey else {
            return
        }
        self.storeKey = uuidString
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
        let temp = UserDefaults.shared.dictionary(forKey: uuidString) as? [String: String] ?? [:]
        self.groupViewModels = raw.groups.map { group in
            ProxyGroupViewModel(group: group, selectedProxy: temp[group.name] ?? group.proxies.first ?? "")
        }
        self.mapping = temp
#if os(macOS)
        self.selectedGroupViewModel = self.groupViewModels.first
#endif
    }
    
    func setSelected(proxy: String, groupViewModel: ProxyGroupViewModel) {
#if os(macOS)
        groupViewModel.selectedProxy = proxy
#endif
        self.mapping[groupViewModel.group.name] = proxy
        UserDefaults.shared.setValue(self.mapping, forKey: self.storeKey)
        Task(priority: .high) {
            guard let controller = await VPNManager.shared.controller else {
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
