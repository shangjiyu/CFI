import SwiftUI
import UniformTypeIdentifiers

struct ConfigListView: View {
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ClashConfig.date, ascending: false)],
        animation: .default
    ) private var configs: FetchedResults<ClashConfig>
            
    private var selection: Binding<UUID?> {
        Binding {
            UUID(uuidString: self.uuidString)
        } set: { new in
            self.uuidString = new?.uuidString ?? ""
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Text("关闭")
                }
                Spacer()
                Button(action: onImportAction) {
                    Text("导入")
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(.accentColor)
            .buttonStyle(.plain)
            .padding()
            
            Divider()
            
            List(configs, id: \.self.uuid!, selection: selection) { config in
                Text(config.name ?? "-")
                    .padding(.vertical, 4)
                    .contextMenu {
                        Button("删除", role: .destructive) {
                            onDeleteAction(config: config)
                        }
                        Button("导出", role: .destructive) {
                            onExportAction(config: config)
                        }
                    }
            }
            .listStyle(.sidebar)
            .frame(width: 320, height: 320)
        }
    }
    
    private func isSelected(_ config: ClashConfig) -> Bool {
        guard let uuid = config.uuid else {
            return false
        }
        return uuid.uuidString == uuidString
    }
    
    private func onImportAction() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [
            UTType(filenameExtension: "yaml"),
            UTType(filenameExtension: "yml")
        ].compactMap { $0 }
        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }
        Task(priority: .high) {
            do {
                try await context.importClashConfig(name: url.deletingPathExtension().lastPathComponent, url: url)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func onExportAction(config: ClashConfig) {
        do {
            guard let uuid = config.uuid else {
                return
            }
            let fileURL = Clash.homeDirectoryURL.appendingPathComponent("\(uuid.uuidString)/config.yaml")
            let panel = NSSavePanel()
            panel.allowedContentTypes = [
                UTType(filenameExtension: "yaml")
            ].compactMap { $0 }
            panel.title = "导出配置"
            panel.nameFieldStringValue = config.name ?? "config"
            panel.canCreateDirectories = true
            panel.isExtensionHidden = false
            guard panel.runModal() == .OK, let destination = panel.url else {
                return
            }
            try FileManager.default.copyItem(at: fileURL, to: destination)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    private func onDeleteAction(config: ClashConfig) {
        guard let uuid = config.uuid else {
            return
        }
        do {
            if uuid.uuidString == uuidString {
                uuidString = ""
            }
            UserDefaults.shared.set(nil, forKey: "\(uuid.uuidString)-PatchGroup")
            try context.deleteClashConfig(config)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
