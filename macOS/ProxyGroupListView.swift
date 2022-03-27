import SwiftUI

struct ProxyGroupListView: View {
    
    @EnvironmentObject var groupVM: ProxyGroupVM
    
    @State private var selection: String = ""
        
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            List(groupVM.groupModels, id: \.self.group.name) { model in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(model.group.name)
                        Text("\(model.group.proxies.count)代理 - \(model.group.type.uppercased())")
                            .font(Font.subheadline)
                    }
                    Spacer()
                    Text(model.isSelectEnable ? model.selection : "")
                }
                .padding()
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(groupVM.groupModel?.group.name == model.group.name ? Color.red.opacity(0.8) : Color.gray.opacity(0.5))
                )
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    groupVM.groupModel = model
                }
            }
            .listStyle(SidebarListStyle())
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Text("策略组")
            }
        }
    }
}
