import SwiftUI
import UniformTypeIdentifiers

struct ConfigListView: View {
    
    @AppStorage(Constant.currentConfigUUID, store: .shared) private var uuidString: String = ""
        
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ClashConfig.date, ascending: false)],
        animation: .default
    ) private var configs: FetchedResults<ClashConfig>
    
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("关闭") {
                    dismiss()
                }
                .foregroundColor(Color.accentColor)
                Spacer()
                Text("配置管理")
                Spacer()
                Button("导入", action: onImportAction)
                    .foregroundColor(Color.accentColor)
            }
            .disabled(isProcessing)
            .buttonStyle(.plain)
            .padding()
            
            Divider()
            
            List(configs) { config in
                HStack {
                    VStack {
                        Text(config.name ?? "-")
                    }
                    Spacer()
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(config.uuid.flatMap({ $0.uuidString }) == uuidString ? Color.accentColor : Color.gray.opacity(0.5))
                )
                .onTapGesture { onTapGesture(config: config) }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button.init("删除", role: .destructive) {
                        onDeleteAction(config: config)
                    }
                }
            }
        }
    }
    
    private func onCloseAction() {
        dismiss()
    }
    
    private func onImportAction() {
        isProcessing = true
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [
            UTType(filenameExtension: "yaml"),
            UTType(filenameExtension: "yml")
        ].compactMap { $0 }
        guard panel.runModal() == .OK, let url = panel.url else {
            return isProcessing = false
        }
        isProcessing = false
        Task(priority: .high) {
            do {
                try await context.importClashConfig(name: url.deletingPathExtension().lastPathComponent, url: url)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func onTapGesture(config: ClashConfig) {
        withAnimation {
            uuidString = config.uuid?.uuidString ?? ""
            onCloseAction()
        }
    }
    
    private func onDeleteAction(config: ClashConfig) {
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
}
