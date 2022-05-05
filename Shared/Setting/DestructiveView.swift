import SwiftUI

struct DestructiveView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    @State private var isAlertPresented: Bool = false
    
    var body: some View {
        Button(role: .destructive) {
            isAlertPresented.toggle()
        } label: {
#if os(macOS)
            Text("移除VPN配置")
                .fontWeight(.bold)
                .foregroundColor(.red)
                .padding(.vertical, 8)
#else
            HStack {
                Spacer()
                Text("移除VPN配置")
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Spacer()
            }
            .contentShape(Rectangle())
#endif
        }
        .disabled(manager.controller == nil)
        .alert("移除VPN配置", isPresented: $isAlertPresented) {
            Button("确定", role: .destructive) {
                Task(priority: .high) {
                    guard let controller = manager.controller else {
                        return
                    }
                    do {
                        try await controller.uninstallVPNConfiguration()
                    } catch {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
        } message: {
            EmptyView()
        }
        .buttonStyle(.plain)
    }
}
