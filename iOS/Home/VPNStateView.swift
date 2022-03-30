import SwiftUI
import NetworkExtension

struct VPNStateView: View {
    
    @EnvironmentObject private var controller: VPNController
    
    @AppStorage(Constant.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    @State private var isVPNOn = false
        
    var body: some View {
        HStack {
            Label("状态", systemImage: "app.connected.to.app.below.fill")
            Spacer()
            Text(self.controller.connectionStatus.displayString)
                .foregroundColor(.secondary)
            Toggle("状态", isOn: .constant(isVPNOn))
                .labelsHidden()
                .allowsHitTesting(false)
                .overlay {
                    Text("VPN")
                        .foregroundColor(.clear)
                        .onTapGesture(perform: toggleVPN)
                }
        }
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
}
