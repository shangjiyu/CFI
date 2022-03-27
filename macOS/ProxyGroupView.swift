import SwiftUI

struct ProxyGroupView: View {
    
    @EnvironmentObject var proxyInfoModel: ProxyInfoModel
    
    private let colums: [GridItem] = [GridItem(.adaptive(minimum: 120))]
    
    @State private var selection: String = ""
    
    private var groupModel: ProxyGroupModel? {
        self.proxyInfoModel.proxyGroupModels.first(where: { $0.group.name == selection })
    }
    
    var body: some View {
        HStack(spacing: 0) {
            List(proxyInfoModel.proxyGroupModels, id: \.self.group.name) { model in
                HStack {
                    Text(model.group.name)
                        .foregroundColor(selection == model.group.name ? Color.accentColor : Color.primary)
                    Spacer()
                    if model.isSelectEnable {
                        Text(model.selection)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    Image(systemName: "chevron.right")
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    selection = model.group.name
                }
            }
            .frame(width: 320)
            ScrollView {
                LazyVGrid(columns: self.colums) {
                    if let model = groupModel {
                        ForEach(model.group.proxies, id: \.self) { proxy in
                            HStack(spacing: 0) {
                                Text(proxy)
                                    .lineLimit(1)
                                Spacer(minLength: 0)
                            }
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill((model.selection == proxy && model.isSelectEnable) ? Color.accentColor : Color.gray.opacity(0.5))
                            )
                            .onTapGesture {
                                guard model.isSelectEnable else {
                                    return
                                }
                                model.selection = proxy
                                proxyInfoModel.setSelected(proxy: proxy, group: model.group.name)
                            }
                        }
                    }
                }
                .padding()
            }
            .foregroundColor(.white)
        }
    }
}
