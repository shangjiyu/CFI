import SwiftUI

struct ProxyGroupView: View {
    
    @EnvironmentObject private var model: PanelInfoModel
    
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
                .onChange(of: selection) { newValue in
                    guard group.isSelectEnable else {
                        return
                    }
                    model.setSelected(proxy: newValue, group: group.name)
                }
                .labelsHidden()
                .pickerStyle(InlinePickerStyle())
                .disabled(!group.isSelectEnable)
            }
        }
        .onAppear {
            selection = model.selectedProxy(group: group.name) ?? group.proxies.first ?? ""
        }
        .navigationTitle(group.name)
    }
}
