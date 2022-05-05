import SwiftUI

struct StatusView: View {
    
    @EnvironmentObject private var controller: VPNController
    
    var body: some View {
        VStack(spacing: 16) {
            ConnectionDurationView()
                .environmentObject(controller)
            ConnectionStatusView()
                .environmentObject(controller)
            TrafficView()
        }
    }
}
