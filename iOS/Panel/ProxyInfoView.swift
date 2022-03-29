import SwiftUI

struct ProxyInfoView: View {
    
    @EnvironmentObject private var model: ProxyInfoModel
    
    var body: some View {
        Form {
            ForEach(model.proxyGroupModels, id: \.group.name) { groupModel in
                NavigationLink {
                    ProxyGroupView()
                        .environmentObject(model)
                        .environmentObject(groupModel)
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.title2)
                            .foregroundColor(Color.accentColor)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(groupModel.group.name)
                            Text("\(groupModel.group.proxies.count)代理 - \(groupModel.group.type.uppercased())")
                                .font(Font.subheadline)
                                .foregroundColor(Color.secondary)
                        }
                        Spacer()
                        Text(groupModel.isSelectEnable ? groupModel.selection : "")
                            .foregroundColor(Color.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
