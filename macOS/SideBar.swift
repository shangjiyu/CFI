import SwiftUI

struct SideBar: View {
        
    @AppStorage("Page", store: .shared) private var page: Page = .home
    
    private var selection: Binding<Page?> {
        Binding {
            page
        } set: { new in
            page = new ?? .home
        }
    }
    
    var body: some View {
        List(selection: selection) {
            ForEach(Page.allCases) { component in
                Label(component.title, systemImage: component.image)
                    .padding(.vertical, 6)
            }
        }
    }
}
