import SwiftUI

struct ProxyListView: View {
    
    @EnvironmentObject private var model: ProxyInfoModel
        
    var body: some View {
        List(model.proxies, id: \.name) { proxy in
            HStack {
                Text(proxy.type.uppercased())
                    .fontWeight(.bold)
                    .font(.system(size: 8))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background {
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(lineWidth: 1.0)
                    }
                    .foregroundColor(Color.accentColor)
                Text(proxy.name)
            }
        }
        .navigationBarTitle("全部代理")
    }
}
