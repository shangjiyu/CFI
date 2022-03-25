import SwiftUI

@main
struct ClashApp: App {
    
#if os(macOS)
    @NSApplicationDelegateAdaptor private var delegate: AppDelegate
#else
    @UIApplicationDelegateAdaptor private var delegate: AppDelegate
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(VPNManager.shared)
                .environment(\.trafficFormatter, ClashTrafficFormatterKey.defaultValue)
                .environment(\.managedObjectContext, CoreDataStack.shared.container.viewContext)
        }
#if os(macOS)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .systemServices) {}
        }
#endif
    }
}
