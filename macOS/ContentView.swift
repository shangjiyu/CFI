import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    
    @AppStorage(Constant.currentConfigUUID, store: .shared) private var uuidString: String = ""
        
    @StateObject var groupVM = ProxyGroupVM()
    
    var body: some View {
        NavigationView {
            SideBar()
            ProxyGroupListView()
                .environmentObject(groupVM)
            ProxyGroupDetailView()
                .environmentObject(groupVM)
        }
        .onChange(of: uuidString) { newValue in
            groupVM.update(uuidString: newValue)
        }
        .onAppear {
            groupVM.update(uuidString: uuidString)
        }
    }
}
