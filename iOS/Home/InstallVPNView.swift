import SwiftUI

struct InstallVPNView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    var body: some View {
        HStack {
            Label("状态", systemImage: "app.connected.to.app.below.fill")
            Spacer()
            Toggle("状态", isOn: .constant(false))
                .labelsHidden()
                .allowsHitTesting(false)
                .overlay {
                    Text("VPN")
                        .foregroundColor(.clear)
                        .onTapGesture {
                            Task(priority: .high) {
                                do {
                                    try await self.manager.installVPNConfiguration()
                                } catch {
                                    debugPrint(error.localizedDescription)
                                }
                            }
                        }
                }
        }
    }
}
