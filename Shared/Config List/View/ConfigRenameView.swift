import SwiftUI

struct ConfigRenameView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    
    private let onCompletion: (String) -> Void
    
    init(name: String, onCompletion: @escaping (String) -> Void) {
        self._name = State(initialValue: name)
        self.onCompletion = onCompletion
    }
    
    var body: some View {
#if os(macOS)
        GroupBox {
            VStack(spacing: 24) {
                Text("重命名")
                    .fontWeight(.bold)
                TextField("", text: $name, prompt: Text("请输入新名称"))
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
                        onCompletion(name.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
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
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .frame(width: 360)
#else
        NavigationView {
            Form {
                TextField("重命名", text: $name, prompt: Text("请输入新名称"))
            }
            .navigationTitle("重命名")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onCompletion(name.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    } label: {
                        Text("确定")
                            .fontWeight(.medium)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
#endif
    }
}
