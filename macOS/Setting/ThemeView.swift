import SwiftUI

struct ThemeView: View {
    
    @AppStorage(Clash.theme) private var theme: Theme = .system
    
    var body: some View {
        Picker("主题: ", selection: $theme) {
            ForEach(Theme.allCases) { level in
                Text(level.description)
                    .padding(.vertical, 4)
            }
        }
        .pickerStyle(.radioGroup)
    }
}
