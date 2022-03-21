import SwiftUI

struct ProxyInfoView: View {
    
    @EnvironmentObject private var model: ProxyInfoModel
    
    var body: some View {
        Form {
            Section("代理") {
                NavigationLink {
                    ProxyListView()
                        .environmentObject(model)
                } label: {
                    HStack {
                        Image(systemName: "square.grid.4x3.fill")
                            .font(.title2)
                            .foregroundColor(Color.accentColor)
                        HStack {
                            Text("全部代理")
                            Spacer()
                            Text("\(model.proxies.count)")
                                .font(Font.body)
                                .foregroundColor(Color.secondary)
                        }
                    }
                }
            }
            Section("策略组") {
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
}
