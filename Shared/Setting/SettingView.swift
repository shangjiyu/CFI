import SwiftUI

struct SettingView: View {
    
    @Environment(\.openURL) var openURL
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Clash.logLevel, store: .shared) private var logLevel: Clash.LogLevel = .silent
#if os(macOS)
    @AppStorage(Clash.theme) private var theme: Theme = .system
#endif
    
    @State private var isAlertPresented: Bool = false
    
    var body: some View {
#if os(macOS)
        Form {
            buildLogLevelView()
            Divider()
            buildThemePicker()
            Divider()
            buildTranslationView()
            Divider()
            buildDestructiveView()
            Spacer()
        }
        .padding()
#else
        NavigationView {
            Form {
                Section {
                    buildLogLevelView()
                }
                Section {
                    buildTranslationView()
                }
                Section {
                    buildDestructiveView()
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
        }
#endif
    }
}

extension SettingView {
    
    @ViewBuilder
    private func buildLogLevelView() -> some View {
#if os(macOS)
        Picker("日志等级: ", selection: $logLevel) {
            ForEach(Clash.LogLevel.allCases) { level in
                Text(level.displayName)
                    .padding(.vertical, 4)
            }
        }
        .pickerStyle(.radioGroup)
        .task(id: logLevel) {
            await self.handleLogLevelChanged()
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
                await self.handleLogLevelChanged()
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
    
    private func handleLogLevelChanged() async {
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

#if os(macOS)
extension SettingView {
    
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
}
#endif

extension SettingView {
    
    @ViewBuilder
    private func buildTranslationView() -> some View {
#if os(macOS)
        Button {
            self.handleTranslationAction()
        } label: {
            Text("订阅转换")
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
#else
        HStack {
            Label("订阅转换", systemImage: "repeat")
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.handleTranslationAction()
        }
#endif
    }
    
    private func handleTranslationAction() {
        guard let url = URL(string: "https://sub.v1.mk") else {
            return
        }
        openURL(url)
    }
}

extension SettingView {
    
    @ViewBuilder
    private func buildDestructiveView() -> some View {
        Button(role: .destructive) {
            isAlertPresented.toggle()
        } label: {
#if os(macOS)
            Text("移除VPN配置")
                .fontWeight(.bold)
                .foregroundColor(.red)
                .padding(.vertical, 8)
#else
            HStack {
                Spacer()
                Text("移除VPN配置")
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Spacer()
            }
            .contentShape(Rectangle())
#endif
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
            EmptyView()
        }
        .buttonStyle(.plain)
    }
}
