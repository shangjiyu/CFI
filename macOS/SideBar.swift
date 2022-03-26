import SwiftUI

struct SideBar: View {
    
    @EnvironmentObject var manager: VPNManager
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                ClashConfigView()
                if let controller = manager.controller {
                    VPNStateView()
                        .toggleStyle(.switch)
                        .environmentObject(controller)
                    VPNConnecteDurationView()
                        .environmentObject(controller)
                } else {
                    InstallVPNView()
                        .toggleStyle(.switch)
                }
            }
            
            Divider()
                        
            ClashTunnelModeView()
            
            Spacer()
            
            VStack(spacing: 8) {
                ClashTrafficUpView()
                Divider()
                ClashTrafficDownView()
            }
        }
        .padding()
    }
}
