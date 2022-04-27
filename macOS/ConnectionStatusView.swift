import SwiftUI

struct ConnectionStatusView: View {
    
    @EnvironmentObject private var controller: VPNController
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 10, height: 10)
                .foregroundColor(indicatorColor)
            Text(controller.connectionStatus.displayString)
        }
    }
    
    private var indicatorColor: Color {
        switch controller.connectionStatus {
        case .invalid:
            return .black
        case .connecting, .connected, .reasserting:
            return .green
        case .disconnecting, .disconnected:
            return .red
        @unknown default:
            return .clear
        }
    }
}
