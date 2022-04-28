import SwiftUI

struct InstallView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    var body: some View {
        Button(action: install) {
            Text("添加VPN配置")
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
        }
        .padding(.vertical, 12)
        .buttonStyle(.plain)
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
