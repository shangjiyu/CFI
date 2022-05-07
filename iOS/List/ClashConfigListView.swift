import SwiftUI

private struct ExportItem: Identifiable {
    let id: UUID
    let items: [Any]
}

struct ClashConfigListView: View {
    
    @EnvironmentObject var manager: VPNManager
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ClashConfig.date, ascending: false)],
        animation: .default
    ) private var configs: FetchedResults<ClashConfig>
    
    @State private var exportItems: [Any]?
        
    var body: some View {
        NavigationView {
            List(configs) { config in
                HStack {
                    Text(config.name ?? "-")
                    Spacer()
                    if config.uuid.flatMap({ $0.uuidString }) == uuidString {
                        Text(Image(systemName: "checkmark"))
                            .fontWeight(.medium)
                            .foregroundColor(Color.accentColor)
                    }
                }
                .lineLimit(1)
                .contentShape(Rectangle())
                .onTapGesture { onCellTapGesture(config: config) }
                .contextMenu {
                    Button(role: nil) {
                        
                    } label: {
                        Label("重命名", systemImage: "pencil")
                    }
                    Button(role: nil) {
                        onCellShareAction(config: config)
                    } label: {
                        Label("导出", systemImage: "square.and.arrow.up")
                    }
                    Button(role: .destructive) {
                        onCellDeleteAction(config: config)
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                }
            }
            .activitySheet(items: $exportItems)
            .navigationBarTitle("配置管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ClashConfigImportButton()
                }
            }
        }
    }
    
    private func onCellTapGesture(config: ClashConfig) {
        let new = config.uuid?.uuidString ?? ""
        let shouldUpdateConfig = !(new == uuidString || new.isEmpty)
        uuidString = new
        if let controller = manager.controller, shouldUpdateConfig {
            Task(priority: .high) {
                do {
                    try await controller.execute(command: .setConfig)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        dismiss()
    }
    
    private func onCellDeleteAction(config: ClashConfig) {
        do {
            if config.uuid.flatMap({ $0.uuidString }) == uuidString {
                uuidString = ""
            }
            UserDefaults.shared.set(nil, forKey: config.uuid?.uuidString ?? "temp")
            try context.deleteClashConfig(config)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    private func onCellShareAction(config: ClashConfig) {
        guard let uuid = config.uuid else {
            return
        }
        let fileURL = Clash.homeDirectoryURL.appendingPathComponent("\(uuid.uuidString)/config.yaml")
        self.exportItems = [fileURL]
    }
}
