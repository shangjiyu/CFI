import SwiftUI

struct ProxyGroupView: View {
    
    @EnvironmentObject private var model: ProxyInfoModel
    @EnvironmentObject private var groupModel: ProxyGroupModel
        
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("名称")
                    Spacer()
                    Text(groupModel.group.name)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("类型")
                    Spacer()
                    Text(groupModel.group.type.uppercased())
                        .foregroundColor(.secondary)
                }
            }
            Section("包含") {
                Picker(groupModel.group.name, selection: groupModel.isSelectEnable ? $groupModel.selection : .constant("")) {
                    ForEach(groupModel.group.proxies, id: \.self) { proxy in
                        Text(proxy)
                    }
                }
                .onChange(of: groupModel.selection) { newValue in
                    guard groupModel.isSelectEnable else {
                        return
                    }
                    model.setSelected(proxy: newValue, group: groupModel.group.name)
                }
                .labelsHidden()
                .pickerStyle(InlinePickerStyle())
                .disabled(!groupModel.isSelectEnable)
            }
        }
        .navigationTitle(groupModel.group.name)
    }
}
