import SwiftUI

struct SideBar: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    var body: some View {
        VStack {
            TunnelModeView()
                .padding()
            ConfigListView()
//            Divider()
//            TrafficView()
//                .padding(.horizontal, 16)
//                .padding(.bottom, 8)
        }
    }
}
