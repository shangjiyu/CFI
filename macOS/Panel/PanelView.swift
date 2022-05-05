import SwiftUI
import Combine

struct PanelView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
        
    @StateObject var viewModel = ProxyGroupListViewModel()
    
    var body: some View {
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
