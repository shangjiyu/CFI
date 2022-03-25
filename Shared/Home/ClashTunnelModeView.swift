import SwiftUI

struct ClashTunnelModeView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Constant.tunnelMode, store: .shared) private var tunnelMode: ClashTunnelMode = .rule
    
    var body: some View {
        buildPicker()
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
    
    private func buildPicker() -> some View {
#if os(macOS)
        VStack(spacing: 0) {
            ForEach(ClashTunnelMode.allCases) { mode in
                HStack {
                    buildContent(mode: mode)
                    Spacer()
                    if tunnelMode == mode {
                        Text(Image(systemName: "checkmark"))
                            .fontWeight(.medium)
                            .foregroundColor(Color.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .frame(height: 50)
                .onTapGesture { tunnelMode = mode }
                if mode != .direct {
                    Divider()
                }
            }
        }
#else
        Picker(selection: $tunnelMode) {
            ForEach(ClashTunnelMode.allCases) { mode in
                buildContent(mode: mode)
                    .padding(.vertical, 6)
            }
        } label: {
            
        }
        .pickerStyle(InlinePickerStyle())
#endif
    }
    
    private func buildContent(mode: ClashTunnelMode) -> some View {
        HStack {
            Image(systemName: mode.imageName)
                .font(.title2)
                .foregroundColor(Color.accentColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(mode.title)
                Text(mode.detail)
                    .font(Font.body)
                    .foregroundColor(Color.secondary)
            }
        }
    }
}

extension ClashTunnelMode {
    
    var imageName: String {
        switch self {
        case .global:
            return "globe"
        case .rule:
            return "arrow.triangle.branch"
        case .direct:
            return "arrow.forward"
        }
    }
    
    var title: String {
        switch self {
        case .global:
            return "全局"
        case .rule:
            return "规则"
        case .direct:
            return "直连"
        }
    }
    
    var detail: String {
        switch self {
        case .global:
            return "流量全部经过指定的全局代理"
        case .rule:
            return "流量会按规则分流"
        case .direct:
            return "流量不会经过任何代理"
        }
    }
}
