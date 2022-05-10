import SwiftUI
import CoreData

class ConfigListViewModel: ObservableObject {
        
    @Published var renamedConfig: ClashConfig? = nil
    @Published var exportItems: [Any]?
    @Published var importLocalFile: Bool = false
    @Published var downloadRemoteFile: Bool = false
    
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
                try await context.importConfig(localFileURL: url, remoteFileURL: nil)
            } catch {
                debugPrint(error.localizedDescription)
            }
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    func onImportRemoteFile(local: URL, remote: URL, context: NSManagedObjectContext) {
        Task {
            do {
                try await context.importConfig(localFileURL: local, remoteFileURL: remote)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
