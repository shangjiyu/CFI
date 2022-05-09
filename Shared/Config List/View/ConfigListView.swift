import SwiftUI

struct ConfigListView: View {
    
    @StateObject private var viewModel = ConfigListViewModel()
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ClashConfig.date, ascending: false)],
        animation: .default
    ) private var configs: FetchedResults<ClashConfig>
    
    var body: some View {
        buildBody()
            .fileImporter(isPresented: $viewModel.importLocalFile, allowedContentTypes: [.yaml]) { result in
                switch result {
                case .success(let url):
                    viewModel.onImportLocalFile(url: url, context: context)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                }
            }
            .sheet(isPresented: $viewModel.downloadRemoteFile) {
                FileDownloadView { url in
                    viewModel.onImportRemoteFile(url: url, context: context)
                }
            }
            .sheet(item: $viewModel.renamedConfig) { config in
                ConfigRenameView(name: config.name ?? "") { new in
                    viewModel.onRename(config: config, newName: new, context: context)
                }
            }
    }
    
    private func buildBody() -> some View {
#if os(macOS)
        VStack(spacing: 0) {
            HStack {
                Button("关闭") { dismiss() }
                Spacer()
                ImportButton(importLocalFile: $viewModel.importLocalFile, downloadRemoteFile: $viewModel.downloadRemoteFile)
            }
            .foregroundColor(.accentColor)
            .buttonStyle(.plain)
            .padding()
            
            buildList()
                .fileExporter(isPresented: viewModel.isFileExporterPresented, document: YAMLFile(exportItems: viewModel.exportItems), contentType: .yaml, defaultFilename: "Config.yml") { result in
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        debugPrint(error.localizedDescription)
                    }
                }
        }
        .frame(width: 540, height: 480)
#else
        NavigationView {
            buildList()
                .navigationBarTitle("配置管理")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ImportButton(importLocalFile: $viewModel.importLocalFile, downloadRemoteFile: $viewModel.downloadRemoteFile)
                    }
                }
                .activitySheet(items: $viewModel.exportItems)
        }
#endif
    }
    
    private func buildList() -> some View {
        List(configs) { config in
            HStack {
                Text(config.name ?? "-")
                Spacer()
                Text(Image(systemName: "checkmark"))
                    .fontWeight(.medium)
                    .foregroundColor(config.uuid.flatMap({ $0.uuidString }) == uuidString ? .accentColor : .clear)
            }
            .lineLimit(1)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.onSelected(config: config)
                dismiss()
            }
            .contextMenu {
                Button(role: nil) {
                    viewModel.renamedConfig = config
                } label: {
                    Label("重命名", systemImage: "pencil")
                }
#if os(macOS)
                Divider()
#endif
                Button(role: nil) {
                    viewModel.onShare(config: config)
                } label: {
#if os(macOS)
                    Label("导出", systemImage: "square.and.arrow.up")
#else
                    Label("分享", systemImage: "square.and.arrow.up")
#endif
                }
#if os(macOS)
                Divider()
#endif
                Button(role: .destructive) {
                    viewModel.onDelete(config: config, context: context)
                } label: {
                    Label("删除", systemImage: "trash")
                }
            }
        }
    }
}
