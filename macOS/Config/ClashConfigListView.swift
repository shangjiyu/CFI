import SwiftUI
import UniformTypeIdentifiers

struct ClashConfigListView: View {
    
    @AppStorage(Constant.currentConfigUUID, store: .shared) private var uuidString: String = ""
        
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ClashConfig.date, ascending: false)],
        animation: .default
    ) private var configs: FetchedResults<ClashConfig>
    
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 120))
    ]
        
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(configs) { config in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(config.name ?? "-")
                                .lineLimit(3)
                                .padding(8)
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(height: 80)
                    .background(.white)
                    .border(config.uuid.flatMap({ $0.uuidString }) == uuidString ? Color.accentColor : Color.white, width: 1.0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.onCellTapGesture(config: config)
                    }
                    .contextMenu {
                        Button {
                            self.onCellDeleteAction(config: config)
                        } label: {
                            Label("删除", systemImage: "plus")
                        }
                    }
                }
            }
            .padding(8)
        }
        .toolbar {
            Button(action: importConfigFile) {
                Image(systemName: "plus")
            }
        }
    }
    
    private func onCellTapGesture(config: ClashConfig) {
        uuidString = config.uuid?.uuidString ?? ""
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
    
    private func importConfigFile() {
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
}
