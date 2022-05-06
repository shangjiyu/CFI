import Foundation

class ProviderViewModel: ObservableObject {
    
    let name: String
    let type: String
    let proxies: [ProxyViewModel]
    @Published var selected: String
    @Published var isHealthCheckProcessing = false
    
    var isSelectEnable: Bool {
        self.type.uppercased() == "SELECTOR"
    }
    
    init(name: String, type: String, selected: String, proxies: [ProxyViewModel]) {
        self.name = name
        self.type = type
        self.selected = selected
        self.proxies = proxies
    }
    
    func select(controller: VPNController, proxy: String) {
        guard self.isSelectEnable else {
            return
        }
        guard let uuid = UserDefaults.shared.string(forKey: Clash.currentConfigUUID) else {
            return
        }
        let key = "\(uuid)-PatchGroup"
        var mapping = UserDefaults.shared.value(forKey: key) as? [String: String] ?? [:]
        mapping[self.name] = proxy
        UserDefaults.shared.set(mapping, forKey: key)
        self.selected = proxy
        Task(priority: .high) {
            do {
                try await controller.execute(command: .setSelectGroup)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func healthCheck(controller: VPNController) async {
        await MainActor.run { self.isHealthCheckProcessing = true }
        do {
            try await controller.execute(command: .healthCheck(self.name))
        } catch {
            debugPrint(error.localizedDescription)
        }
        await MainActor.run { self.isHealthCheckProcessing = false }
    }
}
