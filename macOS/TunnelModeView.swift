import SwiftUI

struct TunnelModeView: View {
    
    @EnvironmentObject private var manager: VPNManager
    @AppStorage(Constant.tunnelMode, store: .shared) private var tunnelMode: ClashTunnelMode = .rule
    
    var body: some View {
        HStack {
            ForEach(ClashTunnelMode.allCases) { mode in
                buildElementView(mode: mode)
                    .onTapGesture {
                        withAnimation {
                            tunnelMode = mode
                        }
                    }
            }
        }
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
    
    @ViewBuilder
    private func buildElementView(mode: ClashTunnelMode) -> some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack {
                Image(systemName: mode.imageName)
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(mode.title)
            }
            .frame(width: 44)
            Spacer(minLength: 0)
        }
        .foregroundColor(.white)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(tunnelMode == mode ? Color.accentColor : Color.gray.opacity(0.5))
        )
    }
}
