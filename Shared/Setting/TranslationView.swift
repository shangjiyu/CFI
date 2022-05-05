import SwiftUI

struct TranslationView: View {
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
#if os(macOS)
        Button {
            self.onTranslationAction()
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
            self.onTranslationAction()
        }
#endif
    }
    
    private func onTranslationAction() {
        guard let url = URL(string: "https://sub.v1.mk") else {
            return
        }
        openURL(url)
    }
}
