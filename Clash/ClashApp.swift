import SwiftUI
import CommonKit

@main
struct ClashApp: App {
    
    @UIApplicationDelegateAdaptor private var delegate: AppDelegate
        
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(VPNManager.shared)
                .environment(\.trafficFormatter, ClashTrafficFormatterKey.defaultValue)
                .environment(\.managedObjectContext, CoreDataStack.shared.container.viewContext)
        }
    }
}
