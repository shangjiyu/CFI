import SwiftUI

struct InstallView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    var body: some View {
        Button(action: install) {
            Text("连接")
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
        }
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
