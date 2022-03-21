import SwiftUI

struct ProxyGroupView: View {
    
    let group: RawProxyGroup
    
    @State private var selection: String = ""
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("名称")
                    Spacer()
                    Text(group.name)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("类型")
                    Spacer()
                    Text(group.type.uppercased())
                        .foregroundColor(.secondary)
                }
            }
            Section("包含") {
                Picker(group.name, selection: group.isSelectEnable ? $selection : .constant("")) {
                    ForEach(group.proxies, id: \.self) { proxy in
                        Text(proxy)
                    }
                }
                .labelsHidden()
                .pickerStyle(InlinePickerStyle())
                .disabled(!group.isSelectEnable)
            }
        }
        .onAppear {
            selection = group.proxies.first ?? ""
        }
        .navigationTitle(group.name)
    }
}
