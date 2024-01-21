import SwiftUI

struct SideBarView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    let binding: Binding<Tab>
        
    private var selection: Binding<Tab?> {
        Binding {
            self.binding.wrappedValue
        } set: { new in
            self.binding.wrappedValue = new ?? .home
        }
    }
            
    var body: some View {
        VStack {
            Image("logo")
                .padding()
            List(Tab.allCases, selection: selection) { tab in
                Label(tab.title, systemImage: tab.systemImageName)
                    .padding(.vertical, 4)
            }
            if let controller = manager.controller {
                StatusView()
                    .environmentObject(controller)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .background(SplitViewControllerInspector())
    }
}
