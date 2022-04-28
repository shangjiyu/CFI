import SwiftUI

struct StatusView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    var body: some View {
        VStack(spacing: 12) {
            if let controller = manager.controller {
                ConnectionStatusView()
                    .environmentObject(controller)
                ConnectionDurationView()
                    .environmentObject(controller)
            }
            TrafficView()
        }
    }
}
