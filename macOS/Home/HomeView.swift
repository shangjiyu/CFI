import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Clash.tunnelMode, store: .shared) private var tunnelMode: Clash.TunnelMode = .rule
    
    var body: some View {
        Form {
            ConfigSwitchView()
            Divider()
            TunnelModeView()
            Divider()
            if let controller = manager.controller {
                ControlView()
                    .environmentObject(controller)
            } else {
                InstallView()
            }
            Spacer()
        }
        .padding()
    }
}
