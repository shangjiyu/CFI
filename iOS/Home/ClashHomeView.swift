import SwiftUI

struct ClashHomeView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    ClashConfigView()
                    if let controller = self.manager.controller {
                        VPNStateView()
                            .environmentObject(controller)
                        ConnectionDurationView()
                            .environmentObject(controller)
                    } else {
                        InstallVPNView()
                    }
                }
                Section {
                    ClashTunnelModeView()
                }
                Section {
                    ClashTrafficUpView()
                    ClashTrafficDownView()
                }
            }
            .navigationBarTitle("主页")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
