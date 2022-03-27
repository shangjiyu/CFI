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
            Divider()
            List(configs) { config in
                HStack {
                    VStack {
                        Text(config.name ?? "-")
                    }
                    Spacer()
                    Button {
                        onDeleteAction(config: config)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.plain)
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(config.uuid.flatMap({ $0.uuidString }) == uuidString ? Color.accentColor : Color.gray.opacity(0.5))
                )
                .onTapGesture { onTapGesture(config: config) }
            }
            Divider()
            Button {
                onImportConfigFileAction()
            } label: {
                HStack {
                    Spacer()
                    Text("添加 Clash 配置")
                    Spacer()
                }
                .font(.body)
                .foregroundColor(Color.white)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor)
                )
            }
            .buttonStyle(.plain)
            .padding()
            .disabled(isProcessing)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Text("Clash 配置")
            }
        }
    }
    
    private func onTapGesture(config: ClashConfig) {
        withAnimation {
            uuidString = config.uuid?.uuidString ?? ""
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
    
    private func onImportConfigFileAction() {
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
            return isProcessing = true
        }
        isProcessing = true
        Task(priority: .high) {
            do {
                try await context.importClashConfig(name: url.deletingPathExtension().lastPathComponent, url: url)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
