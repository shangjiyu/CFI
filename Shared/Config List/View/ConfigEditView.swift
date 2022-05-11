import SwiftUI

struct ConfigEditView: View {
    
    @EnvironmentObject private var manager: VPNManager
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: ConfigEditViewModel
    
    init(config: ClashConfig) {
        self._viewModel = StateObject(wrappedValue: ConfigEditViewModel(config: config))
    }
    
    var body: some View {
#if os(macOS)
        VStack(alignment: .leading, spacing: 20) {
            Text("编辑配置")
                .font(.title2)
            Form {
                TextField("名称: ", text: $viewModel.name, prompt: nil)
                TextField("地址: ", text: $viewModel.url, prompt: nil)
                    .disabled(!viewModel.isLinkEditEnable)
            }
            HStack {
                Spacer()
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("取消")
                        .padding()
                }
                .buttonStyle(.bordered)
                Button(role: nil) {
                    save()
                } label: {
                    Text("确定")
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isConfirmDiable)
            }
        }
        .disabled(viewModel.isProcessing)
        .padding()
        .frame(width: 360)
#else
        NavigationView {
            Form {
                Section {
                    TextField("名称: ", text: $viewModel.name, prompt: Text("请输入名称"))
                    TextField("地址: ", text: $viewModel.url, prompt: Text("请输入地址"))
                        .disabled(!viewModel.isLinkEditEnable)
                }
                Section {
                    Button {
                        save()
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text(viewModel.isProcessing ? "正在下载配置..." : "确定")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isConfirmDiable)
                }
            }
            .disabled(viewModel.isProcessing)
            .interactiveDismissDisabled(viewModel.isProcessing)
            .navigationTitle("编辑配置")
            .navigationBarTitleDisplayMode(.inline)
        }
#endif
    }
    
    private func save() {
        Task {
            do {
                try await viewModel.save(manager: manager)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
