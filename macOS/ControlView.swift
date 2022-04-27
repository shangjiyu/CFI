import SwiftUI
import NetworkExtension

struct ControlView: View {
    
    @EnvironmentObject private var controller: VPNController
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
        
    var body: some View {
        Button(action: toggleVPN) {
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
        }
        .padding(.vertical, 8)
        .buttonStyle(.plain)
        .onChange(of: uuidString) { newValue in
            guard newValue.isEmpty else {
                return
            }
            self.controller.stopVPN()
        }
    }
    
    private func toggleVPN() {
        let isOn: Bool
        switch self.controller.connectionStatus {
        case .connected:
            isOn = true
        case .disconnected:
            isOn = false
        case .invalid, .connecting, .reasserting, .disconnecting:
            return
        @unknown default:
            return
        }
        Task(priority: .high) {
            do {
                isOn ? self.controller.stopVPN() : try await self.controller.startVPN()
            } catch {
                debugPrint(error)
            }
        }
    }
    
    private var title: String {
        switch self.controller.connectionStatus {
        case .invalid:
            return "不可用"
        case .connecting:
            return "正在连接..."
        case .connected:
            return "断开连接"
        case .reasserting:
            return "重连中..."
        case .disconnecting:
            return "正在断开..."
        case .disconnected:
            return "连接"
        @unknown default:
            return "未知"
        }
    }
}
