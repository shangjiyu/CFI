import SwiftUI

struct TranslationView: View {
    
    var body: some View {
        ModalPresentationLink {
            SafariView(url: URL(string: "https://sub.v1.mk")!)
                .ignoresSafeArea()
        } label: {
            HStack {
                Label("订阅转换", systemImage: "doc.text")
                Spacer()
            }
        }
    }
}
