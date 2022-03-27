import SwiftUI

struct SideBar: View {
    
    var body: some View {
        Form {
            TunnelModeView()
            Spacer()
                .frame(height: 20)
            TrafficView()
            Spacer()
        }
        .padding()
    }
}
