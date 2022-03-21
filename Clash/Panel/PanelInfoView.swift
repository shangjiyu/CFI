import SwiftUI

struct PanelInfoView: View {
    
    @EnvironmentObject private var model: PanelInfoModel
    
    var body: some View {
        Form {
            Section("代理") {
                NavigationLink {
                    ProxyListView(proxies: self.model.raw.proxies)
                } label: {
                    HStack {
                        Image(systemName: "square.grid.4x3.fill")
                            .font(.title2)
                            .foregroundColor(Color.accentColor)
                        HStack {
                            Text("全部代理")
                            Spacer()
                            Text("\(model.raw.proxies.count)")
                                .font(Font.body)
                                .foregroundColor(Color.secondary)
                        }
                    }
                }
            }
            Section("策略组") {
                ForEach(model.raw.groups, id: \.name) { group in
                    NavigationLink {
                        ProxyGroupView(group: group)
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.branch")
                                .font(.title2)
                                .foregroundColor(Color.accentColor)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(group.name)
                                Text("\(group.proxies.count)代理 - \(group.type.uppercased())")
                                    .font(Font.subheadline)
                                    .foregroundColor(Color.secondary)
                            }
                            Spacer()
                            Text(group.isSelectEnable ? group.proxies.first ?? "" : "")
                                .foregroundColor(Color.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}
