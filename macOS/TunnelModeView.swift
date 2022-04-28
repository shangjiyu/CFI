import SwiftUI

extension Clash.TunnelMode {
    
    var summary: String {
        switch self {
        case .global:
            return "流量全部经过指定的全局代理"
        case .rule:
            return "流量按规则分流"
        case .direct:
            return "流量不会经过任何代理"
        }
    }
}

struct TunnelModeView: View {
    
    @EnvironmentObject private var manager: VPNManager
    @AppStorage(Clash.tunnelMode, store: .shared) private var tunnelMode: Clash.TunnelMode = .rule
    
    var body: some View {
        Picker("代理模式: ", selection: $tunnelMode) {
            ForEach(Clash.TunnelMode.allCases) { model in
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.title)
                    Text(model.summary)
                        .foregroundColor(.secondary)
                }
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
