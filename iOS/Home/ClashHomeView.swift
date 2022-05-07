import SwiftUI

struct ClashHomeView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    ClashConfigView()
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
    }
}
