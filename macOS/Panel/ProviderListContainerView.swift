import SwiftUI

struct ProviderListContainerView: View {
    
    @EnvironmentObject private var controller: VPNController
    
    var body: some View {
        if controller.connectionStatus == .connected {
            ProviderListView()
        } else {
            PlaceholderView(placeholder: "VPN未连接")
        }
    }
}
