import SwiftUI

struct InstallView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    var body: some View {
        Button(action: install) {
            HStack {
                Spacer()
                Text("添加VPN配置")
                Spacer()
            }
            .font(.body)
            .foregroundColor(Color.white)
            .padding(.vertical, 30)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.purple)
            )
        }
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
