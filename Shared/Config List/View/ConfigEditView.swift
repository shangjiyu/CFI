import SwiftUI

struct ConfigEditView: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let config: ClashConfig
    
    private let isLinkEditEnable: Bool
    
    @State private var name: String
    @State private var urlString: String
    
    init(config: ClashConfig) {
        self._name = State(initialValue: config.name ?? "")
        self._urlString = State(initialValue: config.link?.absoluteString ?? "")
        self.isLinkEditEnable = !(config.link?.isFileURL ?? false)
        self.config = config
    }
    
    var body: some View {
#if os(macOS)
        VStack(alignment: .leading, spacing: 20) {
            Text("编辑配置")
                .font(.title2)
            Form {
                TextField("名称: ", text: $name, prompt: nil)
                TextField("地址: ", text: $urlString, prompt: nil)
                    .disabled(!isLinkEditEnable)
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
                .disabled(isConfirmDiable)
            }
        }
        .padding()
        .frame(width: 360)
#else
        NavigationView {
            Form {
                Section {
                    TextField("名称: ", text: $name, prompt: Text("请输入名称"))
                    TextField("地址: ", text: $urlString, prompt: Text("请输入地址"))
                        .disabled(!isLinkEditEnable)
                }
                Section {
                    Button {
                        save()
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("确定")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .disabled(isConfirmDiable)
                }
            }
            .navigationTitle("编辑配置")
            .navigationBarTitleDisplayMode(.inline)
        }
#endif
    }
    
    private var isConfirmDiable: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func save() {
        config.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        config.link = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines))
        do {
            try context.save()
            dismiss()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
