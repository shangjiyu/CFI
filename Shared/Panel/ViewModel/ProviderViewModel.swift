import Foundation

class ProviderViewModel: ObservableObject {
    
    let name: String
    let type: String
    let proxies: [ProxyViewModel]
    @Published var selected: String
    
    var isSelectEnable: Bool {
        self.type.uppercased() == "SELECTOR"
    }
    
    init(name: String, type: String, selected: String, proxies: [ProxyViewModel]) {
        self.name = name
        self.type = type
        self.selected = selected
        self.proxies = proxies
    }
    
    func select(controller: VPNController, proxy: ProxyViewModel) {
        guard self.isSelectEnable else {
            return
        }
        guard let uuid = UserDefaults.shared.string(forKey: Clash.currentConfigUUID) else {
            return
        }
        let key = "\(uuid)-PatchGroup"
        var mapping = UserDefaults.shared.value(forKey: key) as? [String: String] ?? [:]
        mapping[self.name] = proxy.name
        UserDefaults.shared.set(mapping, forKey: key)
        self.selected = proxy.name
        Task(priority: .high) {
            do {
                try await controller.execute(command: .setSelectGroup)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
