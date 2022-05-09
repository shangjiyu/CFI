import SwiftUI

struct FileDownloadView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = FileDownloadViewModel()
    
    let onCompletion: (URL) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("地址", text: $viewModel.url, prompt: Text("请输入地址"))
                }
                Section {
                    Button {
                        Task {
                            do {
                                onCompletion(try await viewModel.download())
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
                    .disabled(viewModel.url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("下载配置")
            .navigationBarTitleDisplayMode(.inline)
        }
        .disabled(viewModel.isProcessing)
        .interactiveDismissDisabled(viewModel.isProcessing)
    }
}
