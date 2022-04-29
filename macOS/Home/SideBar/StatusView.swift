import SwiftUI

struct StatusView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    var body: some View {
        VStack(spacing: 16) {
            if let controller = manager.controller {
                ConnectionDurationView()
                    .environmentObject(controller)
                ConnectionStatusView()
                    .environmentObject(controller)
            }
            TrafficView()
        }
    }
}
