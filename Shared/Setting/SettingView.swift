import SwiftUI

struct SettingView: View {
        
    var body: some View {
#if os(macOS)
        Form {
            LogLevelView()
            Divider()
            ThemeView()
            Divider()
            TranslationView()
            Divider()
            DestructiveView()
            Spacer()
        }
        .padding()
#else
        NavigationView {
            Form {
                Section {
                    LogLevelView()
                }
                Section {
                    TranslationView()
                }
                Section {
                    DestructiveView()
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
        }
#endif
    }
}
