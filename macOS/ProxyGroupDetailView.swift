import SwiftUI

struct ProxyGroupDetailView: View {
    
    @EnvironmentObject var groupVM: ProxyGroupVM
    
    private let colums: [GridItem] = [GridItem(.adaptive(minimum: 120))]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: self.colums) {
                if let model = groupVM.groupModel {
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
                            groupVM.setSelected(proxy: proxy, group: model.group.name)
                        }
                    }
                }
            }
            .padding()
        }
    }
}
