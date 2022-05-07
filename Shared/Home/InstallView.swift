import SwiftUI

struct InstallView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    var body: some View {
#if os(macOS)
        Button(action: install) {
            Text("添加VPN配置")
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
        }
        .padding(.vertical, 12)
        .buttonStyle(.plain)
#else
        HStack {
            Label("状态", systemImage: "app.connected.to.app.below.fill")
            Spacer()
            Toggle("状态", isOn: .constant(false))
                .labelsHidden()
                .allowsHitTesting(false)
                .overlay {
                    Text("VPN")
                        .foregroundColor(.clear)
                        .onTapGesture(perform: install)
                }
        }
#endif
    }
    
    private func install() {
        Task(priority: .high) {
            do {
                try await self.manager.installVPNConfiguration()
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
