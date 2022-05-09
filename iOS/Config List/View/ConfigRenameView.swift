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
    }
}
