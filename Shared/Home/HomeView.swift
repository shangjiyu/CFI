import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var manager: VPNManager
        
    var body: some View {
#if os(macOS)
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
#else
        NavigationView {
            Form {
                Section {
                    ConfigSwitchView()
                    if let controller = self.manager.controller {
                        ControlView()
                            .environmentObject(controller)
                        ConnectionDurationView()
                            .environmentObject(controller)
                    } else {
                        InstallView()
                    }
                }
                Section {
                    TunnelModeView()
                }
                Section {
                    TrafficView()
                }
            }
            .navigationBarTitle("主页")
            .navigationBarTitleDisplayMode(.inline)
        }
#endif
    }
}
