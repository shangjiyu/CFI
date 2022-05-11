import Foundation

class ConfigEditViewModel: ConfigDownloadViewModel {
    
    @Published var name: String = ""
    
    private let config: ClashConfig
    
    let isLinkEditEnable: Bool
    
    var isConfirmDiable: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(config: ClashConfig) {
        self.config = config
        self.isLinkEditEnable = !(config.link?.isFileURL ?? false)
        super.init()
        self.name = config.name ?? ""
        self.url = config.link?.absoluteString ?? ""
    }
    
    func save(manager: VPNManager) async throws {
        guard let uuid = config.uuid, let context = config.managedObjectContext else {
            return
        }
        let oURLStr = config.link?.absoluteString ?? ""
        if url != oURLStr {
            let (_, data) = try await self.download()
            let targetURL = Clash.homeDirectoryURL.appendingPathComponent("\(uuid.uuidString)").appendingPathComponent("config.yaml")
            FileManager.default.createFile(atPath: targetURL.path, contents: data, attributes: nil)
        }
        await MainActor.run {
            do {
                config.name = name
                config.link = URL(string: url)
                config.update = Date()
                try context.save()
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        guard let uuidString = UserDefaults.shared.string(forKey: Clash.currentConfigUUID), uuidString == uuid.uuidString,
              let controller = manager.controller else {
            return
        }
        do {
            try await controller.execute(command: .setConfig)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
