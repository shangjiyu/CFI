import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            SideBar()
                .frame(minWidth: 240.0)
                .toolbar {
                    ToolbarItem {
                        Button {
                            NSApplication.shared.sendAction(#selector(NSSplitViewController.toggleSidebar(_:)), to: nil, from: nil)
                        } label: {
                            Image(systemName: "sidebar.left")
                        }
                    }
                }
            DetailView()
        }
    }
}
