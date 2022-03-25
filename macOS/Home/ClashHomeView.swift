import SwiftUI

struct ClashHomeView: View {
    
    @EnvironmentObject var manager: VPNManager
    
    @AppStorage("Page", store: .shared) private var page: Page = .home
        
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ClashConfigView()
                    .frame(height: 36)
                    .onTapGesture {
                        page = .config
                    }
                Divider()
                if let controller = manager.controller {
                    VPNStateView()
                        .frame(height: 36)
                        .toggleStyle(.switch)
                        .environmentObject(controller)
                    Divider()
                    VPNConnecteDurationView()
                        .frame(height: 36)
                        .environmentObject(controller)
                } else {
                    InstallVPNView()
                        .frame(height: 36)
                        .toggleStyle(.switch)
                }
            }
            .padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 6).fill(.background))
            .padding()
            
            ClashTunnelModeView()
                .padding(.horizontal, 12)
                .background(RoundedRectangle(cornerRadius: 6).fill(.background))
                .padding()
            
            VStack(spacing: 0) {
                ClashTrafficUpView()
                    .frame(height: 36)
                Divider()
                ClashTrafficDownView()
                    .frame(height: 36)
            }
            .padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 6).fill(.background))
            .padding()
        }
    }
}
