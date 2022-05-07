import SwiftUI

struct TunnelModeView: View {
    
    @EnvironmentObject private var manager: VPNManager
    @AppStorage(Clash.tunnelMode, store: .shared) private var tunnelMode: Clash.TunnelMode = .rule
    
    var body: some View {
        Picker("代理模式: ", selection: $tunnelMode) {
            ForEach(Clash.TunnelMode.allCases) { mode in
                VStack(alignment: .leading, spacing: 4) {
#if os(macOS)
                    Text(mode.title)
                    Text(mode.detail)
                        .foregroundColor(.secondary)
#else
                    Label(mode.title, systemImage: mode.imageName)
#endif
                }
                .padding(.vertical, 4)
            }
        }
#if os(macOS)
        .pickerStyle(.radioGroup)
#else
        .pickerStyle(.inline)
        .labelsHidden()
#endif
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
