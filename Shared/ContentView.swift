import SwiftUI

struct ContentView: View {
    
    @StateObject private var providerListViewModel = ProviderListViewModel()
    
#if os(macOS)
    @AppStorage("TAB_MACOS") private var currentTab: Tab = .home
#endif
    
    var body: some View {
#if os(macOS)
        NavigationView {
            SideBarView(binding: $currentTab)
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
#else
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("主页")
                }
            PanelView()
                .environmentObject(providerListViewModel)
                .tabItem {
                    Image(systemName: "square.stack.3d.up")
                    Text("策略组")
                }
            SettingView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("设置")
                }
        }
#endif
    }
}
