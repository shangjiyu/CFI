import SwiftUI

struct DeleteConfirmButton<Label: View>: View {
    
    private let title: String
    private let action: () -> Void
    private let label: () -> Label
    
    @State private var isPresented = false
    
    init(title: String, action: @escaping () -> Void, label: @escaping () -> Label) {
        self.title = title
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button(action: { isPresented.toggle() }, label: label)
            .confirmationDialog(title, isPresented: $isPresented) {
                Button("确定", role: .destructive, action: action)
                Button("取消", role: .cancel, action: {})
            }
    }
}

struct ConfigListView: View {
    
    @StateObject private var viewModel = ConfigListViewModel()
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ClashConfig.date, ascending: false)],
        animation: .default
    ) private var configs: FetchedResults<ClashConfig>
    
#if os(macOS)
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 3
    )
#endif
    
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
                ConfigDownloadView { url, data in
                    viewModel.onImportRemoteFile(url: url, data: data, context: context)
                }
            }
            .sheet(item: $viewModel.editConfig) { config in
                ConfigEditView(config: config)
            }
    }
    
    private func buildBody() -> some View {
#if os(macOS)
        VStack(spacing: 0) {
            HStack {
                Button("关闭") { dismiss() }
                Spacer()
                ConfigImportButton(importLocalFile: $viewModel.importLocalFile, downloadRemoteFile: $viewModel.downloadRemoteFile)
            }
            .foregroundColor(.accentColor)
            .buttonStyle(.plain)
            .padding()
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns) {
                    ForEach(configs) { config in
                        GroupBox {
                            HStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        HStack(alignment: .top, spacing: 0) {
                                            Text(config.name ?? "")
                                            Text("\n")
                                            Spacer()
                                            Menu {
                                                Button(role: nil) {
                                                    viewModel.editConfig = config
                                                } label: {
                                                    Text("编辑配置")
                                                }
                                                Divider()
                                                Button(role: nil) {
                                                    viewModel.onShare(config: config)
                                                } label: {
                                                    Text("导出配置")
                                                }
                                            } label: {
                                                Image(systemName: "ellipsis")
                                            }
                                            .menuStyle(.borderlessButton)
                                            .menuIndicator(.hidden)
                                            .fixedSize()
                                            .padding(.trailing, -2)
                                        }
                                        .lineLimit(2)
                                    }
                                    HStack {
                                        Spacer()
                                        
                                        if let url = config.link, !url.isFileURL {
                                            Button(role: nil) {
                                                viewModel.onUpdate(config: config, manager: manager)
                                            } label: {
                                                Image(systemName: "goforward")
                                                    .foregroundColor(.accentColor)
                                            }
                                            .buttonStyle(.plain)
                                            .disabled(viewModel.updatingConfig == config)
                                        }
                                        
                                        DeleteConfirmButton(title: "删除”\(config.name ?? "-" )“?") {
                                            viewModel.onDelete(config: config, context: context)
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .lineLimit(1)
                                Spacer()
                            }
                            .padding(8)
                        }
                        .groupBoxStyle(SelectableGroupBoxStyle(isSelected: config.uuid?.uuidString == uuidString))
                        .onTapGesture {
                            viewModel.onSelected(config: config)
                            dismiss()
                        }
                    }
                }
                .padding()
            }
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
            List(configs) { config in
                HStack {
                    Text(config.name ?? "-")
                    if viewModel.updatingConfig == config {
                        ProgressView()
                    }
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
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        viewModel.onDelete(config: config, context: context)
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                    .tint(.red)
                    
                    Button(role: nil) {
                        viewModel.editConfig = config
                    } label: {
                        Label("重命名", systemImage: "square.and.pencil")
                    }
                    .tint(.accentColor)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    if let url = config.link, !url.isFileURL {
                        Button(role: nil) {
                            viewModel.onUpdate(config: config, manager: manager)
                        } label: {
                            Label("更新", systemImage: "goforward")
                        }
                        .tint(.green)
                        .disabled(viewModel.updatingConfig == config)
                    }
                    
                    Button(role: nil) {
                        viewModel.onShare(config: config)
                    } label: {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }
                    .tint(.yellow)
                }
            }
            .navigationBarTitle("配置管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ConfigImportButton(importLocalFile: $viewModel.importLocalFile, downloadRemoteFile: $viewModel.downloadRemoteFile)
                }
            }
            .activitySheet(items: $viewModel.exportItems)
        }
#endif
    }
}
