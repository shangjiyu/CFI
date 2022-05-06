import SwiftUI

struct ContentView: View {
    
    @StateObject private var providerListViewModel = ProviderListViewModel()
    
    var body: some View {
        TabView {
            ClashHomeView()
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
    }
}
