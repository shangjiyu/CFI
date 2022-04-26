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
#if !os(macOS)
                .environment(\.horizontalSizeClass, .compact)
#endif
        }
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("导入") {
                    NotificationCenter.default.post(name: NSNotification.Name("ImportFile"), object: nil)
                }
                .keyboardShortcut("I", modifiers: [.command])
            }
            CommandGroup(replacing: .systemServices) {}
        }
#endif
        
#if os(macOS)
        Settings {
            SettingsView()
                .environmentObject(VPNManager.shared)
        }
#endif
    }
}
