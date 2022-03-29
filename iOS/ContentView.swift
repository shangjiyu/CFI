import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ClashHomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("主页")
                }
            PanelView()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
