import SwiftUI

struct ClashTunnelModeView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Clash.tunnelMode, store: .shared) private var tunnelMode: Clash.TunnelMode = .rule
    
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
        Picker(selection: $tunnelMode) {
            ForEach(Clash.TunnelMode.allCases) { mode in
                Label(mode.title, systemImage: mode.imageName)
            }
        } label: {
            
        }
        .pickerStyle(InlinePickerStyle())
    }
}
