import SwiftUI
import CoreData

class ConfigListViewModel: ObservableObject {
        
    @Published var editConfig: ClashConfig? = nil
    @Published var exportItems: [Any]?
    @Published var importLocalFile: Bool = false
    @Published var downloadRemoteFile: Bool = false
    @Published var updatingConfig: ClashConfig?
    
    var isFileExporterPresented: Binding<Bool> {
        Binding {
            guard let items = self.exportItems else {
                return false
            }
            return items.first != nil
        } set: { _ in
            self.exportItems = nil
        }
    }
    
    func onSelected(config: ClashConfig) {
        guard let uuid = config.uuid else {
            return
        }
        UserDefaults.shared.set(uuid.uuidString, forKey: Clash.currentConfigUUID)
    }
    
    func onUpdate(config: ClashConfig, manager: VPNManager) {
        guard let uuid = config.uuid, let url = config.link else {
            return
        }
        Task {
            await MainActor.run {
                updatingConfig = config
            }
            let result: Result<Void, Error>
            do {
                let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
                let directoryURL = Clash.homeDirectoryURL.appendingPathComponent("\(uuid.uuidString)")
                let targetURL = directoryURL.appendingPathComponent("config.yaml")
                FileManager.default.createFile(atPath: targetURL.path, contents: data, attributes: nil)
                result = .success(())
            } catch {
                result = .failure(error)
            }
            await MainActor.run {
                updatingConfig = nil
            }
            switch result {
            case .success:
                guard let uuidString = UserDefaults.shared.string(forKey: Clash.currentConfigUUID), uuidString == uuid.uuidString,
                      let controller = manager.controller else {
                    return
                }
                try await controller.execute(command: .setConfig)
            case .failure(let error):
                throw error
            }
        }
    }
    
    func onRename(config: ClashConfig, newName: String, context: NSManagedObjectContext) {
        guard (config.name ?? "") !=  newName && !newName.isEmpty else {
            return
        }
        config.name = newName
        do {
            try context.save()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func onShare(config: ClashConfig) {
        guard let uuid = config.uuid else {
            return
        }
        let fileURL = Clash.homeDirectoryURL.appendingPathComponent("\(uuid.uuidString)/config.yaml")
        self.exportItems = [fileURL]
    }
    
    func onDelete(config: ClashConfig, context: NSManagedObjectContext) {
        guard let uuid = config.uuid else {
            return
        }
        do {
            if UserDefaults.shared.string(forKey: Clash.currentConfigUUID) == uuid.uuidString {
                UserDefaults.shared.set(nil, forKey: Clash.currentConfigUUID)
            }
            try context.deleteClashConfig(config)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func onImportLocalFile(url: URL, context: NSManagedObjectContext) {
        Task {
            guard url.startAccessingSecurityScopedResource() else {
                return
            }
            do {
                try await context.importConfig(url: url, data: try Data(contentsOf: url))
            } catch {
                debugPrint(error.localizedDescription)
            }
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    func onImportRemoteFile(url: URL, data: Data, context: NSManagedObjectContext) {
        Task {
            do {
                try await context.importConfig(url: url, data: data)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
