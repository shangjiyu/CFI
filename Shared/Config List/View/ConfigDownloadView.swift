import SwiftUI

struct ConfigDownloadView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = ConfigDownloadViewModel()
    
    let onCompletion: (URL, Data) -> Void
    
    var body: some View {
#if os(macOS)
        GroupBox {
            VStack(spacing: 24) {
                Text("下载配置")
                    .fontWeight(.bold)
                TextField("", text: $viewModel.url, prompt: Text("请输入配置地址"))
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
                        Task {
                            do {
                                let res = try await viewModel.download()
                                onCompletion(res.0, res.1)
                                dismiss()
                            } catch {
                                debugPrint(error.localizedDescription)
                            }
                        }
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
                    .disabled(viewModel.isProcessing || viewModel.url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .frame(width: 360)
#else
        NavigationView {
            Form {
                Section {
                    TextField("地址", text: $viewModel.url, prompt: Text("请输入地址"))
                }
                Section {
                    Button {
                        Task {
                            do {
                                let res = try await viewModel.download()
                                onCompletion(res.0, res.1)
                                dismiss()
                            } catch {
                                debugPrint(error.localizedDescription)
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isProcessing {
                                ProgressView()
                            } else {
                                Text("下载")
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isProcessing || viewModel.url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("下载配置")
            .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled(viewModel.isProcessing)
#endif
    }
}
