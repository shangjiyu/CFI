import SwiftUI
import NetworkExtension

struct StateView: View {
    
    @EnvironmentObject private var controller: VPNController
    
    @AppStorage(Constant.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    @State private var isVPNOn = false
    
    var body: some View {
        VStack {
            HStack {
                Text("状态")
                Spacer()
                Text(self.controller.connectionStatus.displayString)
                Toggle("状态", isOn: .constant(isVPNOn))
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .allowsHitTesting(false)
                    .overlay {
                        Text("VPN")
                            .foregroundColor(.clear)
                            .onTapGesture(perform: toggleVPN)
                    }
            }
            TimelineView(.periodic(from: Date(), by: 1.0)) { context in
                HStack {
                    Text("连接时间")
                    Spacer()
                    Text(durationFormatString(current: context.date))
                }
            }
        }
        .foregroundColor(Color.white)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purple)
        )
        .onChange(of: controller.connectionStatus, perform: updateToggle(_:))
        .onAppear { self.updateToggle(controller.connectionStatus) }
        .onChange(of: uuidString) { newValue in
            guard newValue.isEmpty else {
                return
            }
            self.controller.stopVPN()
        }
    }
    
    private func updateToggle(_ status: NEVPNStatus) {
        withAnimation(.default) {
            switch status {
            case .invalid, .disconnecting, .disconnected:
                isVPNOn = false
            case .connecting, .connected, .reasserting:
                isVPNOn = true
            @unknown default:
                isVPNOn = false
            }
        }
    }
    
    private func toggleVPN() {
        switch self.controller.connectionStatus {
        case .invalid, .connected, .disconnected:
            break
        case .connecting, .disconnecting, .reasserting:
            return
        @unknown default:
            break
        }
        withAnimation(.default) {
            isVPNOn.toggle()
        }
        let isOn = isVPNOn
        Task(priority: .high) {
            do {
                isOn ? try await self.controller.startVPN() : self.controller.stopVPN()
            } catch {
                debugPrint(error)
            }
        }
    }
    
    private func durationFormatString(current: Date) -> String {
        guard let date = controller.connectedDate else {
            return "--:--:--"
        }
        let duration = Int64(abs(date.distance(to: current)))
        let hs = duration / 3600
        let ms = duration % 3600 / 60
        let ss = duration % 60
        return String(format: "%02d:%02d:%02d", hs, ms, ss)
    }
}

extension NEVPNStatus {
    
    var displayString: String {
        switch self {
        case .invalid:
            return "不可用"
        case .connecting:
            return "正在连接..."
        case .connected:
            return "已连接"
        case .reasserting:
            return "正在重新连接..."
        case .disconnecting:
            return "正在断开连接..."
        case .disconnected:
            return "未连接"
        @unknown default:
            return "未知"
        }
    }
}
