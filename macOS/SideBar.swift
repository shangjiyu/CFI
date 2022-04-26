import SwiftUI

struct SideBar: View {
        
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            TunnelModeView()
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            Divider()
            Spacer()
                .frame(height: 8)
            ConfigListView()
        }
    }
}
