import SwiftUI

struct ContentView: View {
    
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
            case .setting:
                SettingView()
            }
        }
        .frame(height: 540)
    }
}
