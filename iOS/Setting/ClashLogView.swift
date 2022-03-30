import SwiftUI

struct ClashLogView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Clash.logLevel, store: .shared) private var logLevel: Clash.LogLevel = .silent
        
    var body: some View {
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
                guard let controller = self.manager.controller else {
                    return
                }
                do {
                    try await controller.execute(command: .setLogLevel)
                } catch {
                    debugPrint(error)
                }
            }
        } label: {
            HStack {
                Label("日志等级", systemImage: "doc.text")
                Spacer()
                Text(logLevel.displayName)
                    .fontWeight(.bold)
            }
        }
    }
}
