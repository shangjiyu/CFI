import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Clash.logLevel, store: .shared) private var logLevel: Clash.LogLevel = .silent
    
    var body: some View {
        Form {
            Picker("日志等级", selection: $logLevel) {
                ForEach(Clash.LogLevel.allCases) { level in
                    Text(level.displayName)
                }
            }
            .pickerStyle(.radioGroup)
        }
        .padding()
        .frame(width: 300, alignment: .center)
        .task(id: logLevel) {
            guard let controller = self.manager.controller else {
                return
            }
            do {
                try await controller.execute(command: .setLogLevel)
            } catch {
                debugPrint(error)
            }
        }
    }
}
