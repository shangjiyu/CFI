import SwiftUI

struct SettingView: View {
    
    @Environment(\.openURL) var openURL
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Clash.logLevel, store: .shared) private var logLevel: Clash.LogLevel = .silent
    @AppStorage(Clash.theme) private var theme: Theme = .system
    
    @State private var isAlertPresented: Bool = false
    
    var body: some View {
        Form {
            buildLevelPicker()
            Divider()
            buildThemePicker()
            Divider()
            buildTranslationButton()
            Divider()
            buildDestructiveButton()
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func buildLevelPicker() -> some View {
        Picker("日志等级: ", selection: $logLevel) {
            ForEach(Clash.LogLevel.allCases) { level in
                Text(level.displayName)
                    .padding(.vertical, 4)
            }
        }
        .pickerStyle(.radioGroup)
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
    
    @ViewBuilder
    private func buildThemePicker() -> some View {
        Picker("主题: ", selection: $theme) {
            ForEach(Theme.allCases) { level in
                Text(level.description)
                    .padding(.vertical, 4)
            }
        }
        .pickerStyle(.radioGroup)
    }
    
    @ViewBuilder
    private func buildTranslationButton() -> some View {
        Button {
            guard let url = URL(string: "https://sub.v1.mk") else {
                return
            }
            openURL(url)
        } label: {
            Text("订阅转换")
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func buildDestructiveButton() -> some View {
        Button {
            isAlertPresented.toggle()
        } label: {
            Text("移除VPN配置")
                .fontWeight(.bold)
                .foregroundColor(.red)
                .padding(.vertical, 8)
            
        }
        .disabled(manager.controller == nil)
        .alert("移除VPN配置", isPresented: $isAlertPresented) {
            Button("确定", role: .destructive) {
                Task(priority: .high) {
                    guard let controller = manager.controller else {
                        return
                    }
                    do {
                        try await controller.uninstallVPNConfiguration()
                    } catch {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
        } message: {
            Text("移除VPN配置后, 您可以重新添加VPN配置")
        }
        .buttonStyle(.plain)
    }
}
