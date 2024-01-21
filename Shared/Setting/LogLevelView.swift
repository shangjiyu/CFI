import SwiftUI

struct LogLevelView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Clash.logLevel, store: .shared) private var logLevel: Clash.LogLevel = .silent
    
    var body: some View {
#if os(macOS)
        Picker("日志等级: ", selection: $logLevel) {
            ForEach(Clash.LogLevel.allCases) { level in
                Text(level.displayName)
                    .padding(.vertical, 4)
            }
        }
        .pickerStyle(.radioGroup)
        .task(id: logLevel) {
            await self.onLogLevelChanged()
        }
#else
        NavigationLink {
            Form {
                Picker("日志等级", selection: $logLevel) {
                    ForEach(Clash.LogLevel.allCases) { level in
                        Text(level.displayName)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            .navigationBarTitle("日志等级")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: logLevel) {
                await self.onLogLevelChanged()
            }
        } label: {
            HStack {
                Label("日志等级", systemImage: "doc.text")
                Spacer()
                Text(logLevel.displayName)
                    .fontWeight(.bold)
            }
        }
#endif
    }
    
    private func onLogLevelChanged() async {
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
