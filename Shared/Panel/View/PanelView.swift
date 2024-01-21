import SwiftUI
import Combine

struct PanelView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    var body: some View {
#if os(macOS)
        buildBody()
#else
        NavigationView {
            buildBody()
                .navigationBarTitle("策略组")
                .navigationBarTitleDisplayMode(.inline)
        }
#endif
    }
    
    @ViewBuilder
    private func buildBody() -> some View {
        if uuidString.isEmpty {
            PlaceholderView(placeholder: "未选择配置")
        } else {
            if let controller = manager.controller {
                ProviderListContainerView()
                    .environmentObject(controller)
            } else {
                PlaceholderView(placeholder: "VPN未连接")
            }
        }
    }
}
