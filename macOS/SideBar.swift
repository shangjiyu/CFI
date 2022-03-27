import SwiftUI

struct SideBar: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    var body: some View {
        Form {
            if let controller = manager.controller {
                StateView()
                    .environmentObject(controller)
            } else {
                InstallView()
            }
            Spacer()
                .frame(height: 20)
            TunnelModeView()
            Spacer()
                .frame(height: 20)
            TrafficView()
            Spacer()
        }
        .padding()
    }
}
