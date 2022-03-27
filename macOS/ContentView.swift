import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            SideBar()
            ConfigListView()
            PanelView()
        }
    }
}
