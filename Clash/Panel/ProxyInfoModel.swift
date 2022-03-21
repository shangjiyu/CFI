import SwiftUI
import CommonKit
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

class ProxyGroupModel: ObservableObject {
    
    @Published var selection: String
    
    let group: RawProxyGroup
    
    init(group: RawProxyGroup, selection: String) {
        self.group = group
        self.selection = selection
    }
    
    var isSelectEnable: Bool {
        self.group.type.uppercased() == "SELECT"
    }
}

@MainActor class ProxyInfoModel: ObservableObject {
    
    let proxies: [RawProxy]
    let proxyGroupModels: [ProxyGroupModel]
    
    private let storeKey: String
    
    @Published private var mapping: [String: String]
    
    init(id: String) {
        self.storeKey = id
        let raw: RawConfig
        do {
            raw = try YAMLDecoder().decode(
                from: try Data(
                    contentsOf: Constant.homeDirectoryURL.appendingPathComponent("\(id)/config.yaml")
                )
            )
        } catch {
            raw = RawConfig(proxies: [], groups: [])
        }
        self.proxies = raw.proxies
        let temp = UserDefaults.shared.dictionary(forKey: id) as? [String: String] ?? [:]
        self.proxyGroupModels = raw.groups.map { group in
            ProxyGroupModel(group: group, selection: temp[group.name] ?? group.proxies.first ?? "")
        }
        self.mapping = temp
    }
    
    func selectedProxy(group: String) -> String? {
        self.mapping[group]
    }
    
    func setSelected(proxy: String, group: String) {
        self.mapping[group] = proxy
        UserDefaults.shared.setValue(self.mapping, forKey: self.storeKey)
        guard let controller = VPNManager.shared.controller else {
            return
        }
        Task(priority: .high) {
            do {
                try await controller.execute(command: .patchSelectGroup)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
