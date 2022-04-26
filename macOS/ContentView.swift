import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    
    @EnvironmentObject private var manager: VPNManager
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
        
    @StateObject var viewModel = ProxyGroupListViewModel()
    
    var body: some View {
        NavigationView {
            SideBar()
                .frame(minWidth: 250)
                .toolbar {
                    ToolbarItem {
                        Button {
                            NSApplication.shared.sendAction(#selector(NSSplitViewController.toggleSidebar(_:)), to: nil, from: nil)
                        } label: {
                            Image(systemName: "sidebar.left")
                        }
                    }
                    ToolbarItem(placement: .status) {
                        if let controller = manager.controller {
                            StateView()
                                .environmentObject(controller)
                        } else {
                            InstallView()
                        }
                    }
                }
            ProxyGroupListView()
                .frame(minWidth: 480)
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
