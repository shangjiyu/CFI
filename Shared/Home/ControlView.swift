import SwiftUI
import NetworkExtension

struct ControlView: View {
    
    @EnvironmentObject private var controller: VPNController
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    @State private var isOn: Bool = false
        
    var body: some View {
        buildBody()
            .toggleStyle(.switch)
            .allowsHitTesting(allowsHitTesting)
            .onAppear { self.onVPNStatusChanged(status: self.controller.connectionStatus) }
            .onChange(of: isOn, perform: onToggleAction(isOn:))
            .onChange(of: uuidString, perform: onClashConfigChanged(uuidString:))
            .onChange(of: controller.connectionStatus, perform: onVPNStatusChanged(status:))
    }
    
    @ViewBuilder
    private func buildBody() -> some View {
#if os(macOS)
        Toggle("状态: ", isOn: $isOn)
            .padding(.vertical, 8)
#else
        HStack {
            Label("状态", systemImage: "app.connected.to.app.below.fill")
            Spacer()
            ConnectionStatusView()
                .foregroundColor(.secondary)
            Toggle("状态", isOn: $isOn)
                .labelsHidden()
        }
#endif
    }
    
    private var allowsHitTesting: Bool {
        switch self.controller.connectionStatus {
        case .connected, .disconnected:
            return true
        case .invalid, .connecting, .disconnecting, .reasserting:
            return false
        @unknown default:
            return false
        }
    }
    
    private func onToggleAction(isOn: Bool) {
        Task(priority: .high) {
            do {
                isOn ? try await self.controller.startVPN() : self.controller.stopVPN()
            } catch {
                debugPrint(error)
            }
        }
    }
    
    private func onVPNStatusChanged(status: NEVPNStatus) {
        withAnimation {
            switch status {
            case .connected:
                self.isOn = true
            case .invalid, .disconnected:
                self.isOn = false
            case .connecting, .disconnecting, .reasserting:
                return
            @unknown default:
                return
            }
        }
    }
    
    private func onClashConfigChanged(uuidString: String) {
        if uuidString.isEmpty {
            self.controller.stopVPN()
        } else {
            Task(priority: .high) {
                do {
                    try await controller.execute(command: .setConfig)
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
}
