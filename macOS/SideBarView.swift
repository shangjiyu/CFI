import SwiftUI

struct SideBarView: View {
    
    let binding: Binding<Tab>
        
    private var selection: Binding<Tab?> {
        Binding {
            self.binding.wrappedValue
        } set: { new in
            self.binding.wrappedValue = new ?? .home
        }
    }
            
    var body: some View {
        VStack {
            List(Tab.allCases, selection: selection) { tab in
                Label(tab.title, systemImage: tab.systemImageName)
                    .padding(.vertical, 4)
            }
            StatusView()
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
    }
}
