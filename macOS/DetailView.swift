import SwiftUI

struct DetailView: View {
    
    @AppStorage("Page", store: .shared) private var page: Page = .home
    
    var body: some View {
        switch page {
        case .home:
            ClashHomeView()
        case .config:
            Text("Hello, config!")
        case .panel:
            Text("Hello, panel!")
        case .log:
            Text("Hello, log!")
        case .setting:
            Text("Hello, setting!")
        }
    }
}
