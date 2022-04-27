import SwiftUI

struct TunnelModeView: View {
    
    @EnvironmentObject private var manager: VPNManager
    @AppStorage(Clash.tunnelMode, store: .shared) private var tunnelMode: Clash.TunnelMode = .rule
    
    var body: some View {
        Picker("代理模式: ", selection: $tunnelMode) {
            ForEach(Clash.TunnelMode.allCases) {
                Text($0.title)
                    .padding(.vertical, 4)
            }
        }
        .pickerStyle(.radioGroup)
        .task(id: tunnelMode) {
            guard let controller = self.manager.controller else {
                return
            }
            do {
                try await controller.execute(command: .setTunnelMode)
            } catch {
                debugPrint(error)
            }
        }
    }
}
