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
    
    @State private var configRenamed: ClashConfig?
            
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
                        Button("重命名", role: nil) {
                            configRenamed = config
                        }
                        Divider()
                        Button("导出配置", role: nil) {
                            onExportAction(config: config)
                        }
                        Divider()
                        Button {
                            onDeleteAction(config: config)
                        } label: {
                            Text("删除配置")
                                .foregroundColor(.red)
                        }
                    }
            }
            .listStyle(.sidebar)
        }
        .frame(width: 320, height: 480)
        .sheet(item: $configRenamed, onDismiss: nil) { config in
            ConfigRenameDialog(name: config.name ?? "") { newName in
                guard newName != (config.name ?? "") else {
                    return
                }
                do {
                    config.name = newName
                    try context.save()
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }
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

struct ConfigRenameDialog: View {
        
    @Environment(\.dismiss) private var dismiss
    
    @State private var text: String
    
    private let completion: (String) -> Void
    
    init(name: String, completion: @escaping (String) -> Void) {
        self._text = State(initialValue: name)
        self.completion = completion
    }
    
    var body: some View {
        GroupBox {
            VStack(spacing: 24) {
                Text("重命名")
                    .fontWeight(.bold)
                TextField("", text: $text, prompt: nil)
                    .labelsHidden()
                    .padding(.horizontal, 12)
                HStack(spacing: 8) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("取消")
                            Spacer()
                        }
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(Color.gray.opacity(0.2))
                        )
                    }
                    Button {
                        completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("确定")
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(Color.accentColor)
                        )
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .frame(width: 360)
    }
}
