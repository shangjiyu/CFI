import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
        
    @StateObject var viewModel = ProxyGroupListViewModel()
    
    var body: some View {
        NavigationView {
            SideBar()
            ProxyGroupListView()
                .environmentObject(viewModel)
            ProxyGroupDetailView()
                .environmentObject(viewModel)
        }
        .onChange(of: uuidString) { newValue in
            viewModel.update(uuidString: newValue)
        }
        .onAppear {
            viewModel.update(uuidString: uuidString)
        }
    }
}
