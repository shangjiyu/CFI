import Foundation
import Yams

class ProxyGroupVM: ObservableObject {
    
    @Published private var mapping: [String: String] = [:]
    
    private(set) var groupModels: [ProxyGroupModel] = []
    
    private var storeKey: String = ""
    
    @Published var groupModel: ProxyGroupModel?
    
    init() {}
    
    func update(uuidString: String) {
        defer {
            objectWillChange.send()
        }
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
        self.groupModels = raw.groups.map { group in
            ProxyGroupModel(group: group, selection: temp[group.name] ?? group.proxies.first ?? "")
        }
        self.mapping = temp
        self.groupModel = nil
    }
    
    @MainActor func setSelected(proxy: String, group: String) {
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
