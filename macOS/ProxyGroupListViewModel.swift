import Foundation
import Yams

class ProxyGroupViewModel: ObservableObject {
    
    @Published fileprivate(set) var selectedProxy: String
    
    let group: RawProxyGroup
    
    init(group: RawProxyGroup, selectedProxy proxy: String) {
        self.group = group
        self.selectedProxy = proxy
    }
    
    var isSelectable: Bool {
        self.group.type.uppercased() == "SELECT"
    }
}

class ProxyGroupListViewModel: ObservableObject {
    
    @Published private var mapping: [String: String] = [:]
    @Published var groupViewModels: [ProxyGroupViewModel] = []
    @Published var selectedGroupViewModel: ProxyGroupViewModel?
    
    private var storeKey: String = ""
    
    init() {}
    
    func update(uuidString: String) {
        self.storeKey = uuidString
        let raw: RawConfig
        do {
            raw = try YAMLDecoder().decode(
                from: try Data(
                    contentsOf: Constant.homeDirectoryURL.appendingPathComponent("\(uuidString)/config.yaml")
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
        self.selectedGroupViewModel = nil
    }
    
    func setSelected(proxy: String, groupViewModel: ProxyGroupViewModel) {
        groupViewModel.selectedProxy = proxy
        self.mapping[groupViewModel.group.name] = proxy
        UserDefaults.shared.setValue(self.mapping, forKey: self.storeKey)
        Task(priority: .high) {
            guard let controller = await VPNManager.shared.controller else {
                return
            }
            do {
                try await controller.execute(command: .patchSelectGroup)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
