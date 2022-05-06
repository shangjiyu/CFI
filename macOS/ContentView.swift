import SwiftUI

struct ContentView: View {
    
    @StateObject private var providerListViewModel = ProviderListViewModel()
    
    @AppStorage("TAB_MACOS") private var currentTab: Tab = .home
    
    var body: some View {
        NavigationView {
            SideBarView(binding: $currentTab)
                .background(SplitViewControllerInspector())
            switch currentTab {
            case .home:
                HomeView()
            case .panel:
                PanelView()
                    .environmentObject(providerListViewModel)
            case .setting:
                SettingView()
            }
        }
        .frame(height: 540)
    }
}
