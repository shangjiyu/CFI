import SwiftUI

struct PanelView: View {
    
    @AppStorage(Constant.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    var body: some View {
        NavigationView {
            _body
                .navigationBarTitle("策略组")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var _body: some View {
        if uuidString.isEmpty {
            Text("未选择配置")
                .foregroundColor(.secondary)
        } else {
            ProxyInfoView()
                .environmentObject(ProxyInfoModel(id: uuidString))
        }
    }
}
