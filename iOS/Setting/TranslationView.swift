import SwiftUI

struct TranslationView: View {
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        HStack {
            Label("订阅转换", systemImage: "repeat")
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard let url = URL(string: "https://sub.v1.mk") else {
                return
            }
            openURL(url)
        }
    }
}
