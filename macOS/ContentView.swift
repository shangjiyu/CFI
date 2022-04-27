import SwiftUI

struct ContentView: View {
    
    @AppStorage("TAB_MACOS") private var currentTab: Tab = .home
    
    var body: some View {
        NavigationView {
            SideBarView(binding: $currentTab)
                .frame(height: 480)
            switch currentTab {
            case .home:
                HomeView()
            case .panel:
                PanelView()
            case .setting:
                SettingView()
            }
        }
    }
}
