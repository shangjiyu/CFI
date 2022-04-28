import SwiftUI
import NetworkExtension

struct ControlView: View {
    
    @EnvironmentObject private var controller: VPNController
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    @State private var isOn: Bool = false
        
    var body: some View {
        Toggle("状态: ", isOn: $isOn)
            .padding(.vertical, 8)
            .toggleStyle(.switch)
            .allowsHitTesting(allowsHitTesting)
            .onAppear {
                self.isOn = {
                    switch self.controller.connectionStatus {
                    case .connecting, .connected, .reasserting:
                        return true
                    case .disconnecting, .disconnected, .invalid:
                        return false
                    @unknown default:
                        return false
                    }
                }()
            }
            .onChange(of: isOn) { newValue in
                toggleVPN(isOn: newValue)
            }
            .onChange(of: uuidString) { newValue in
                if newValue.isEmpty {
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
    
    private func toggleVPN(isOn: Bool) {
        Task(priority: .high) {
            do {
                isOn ? try await self.controller.startVPN() : self.controller.stopVPN()
            } catch {
                debugPrint(error)
            }
        }
    }
}
