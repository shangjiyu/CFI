import SwiftUI

@main
struct ClashApp: App {
    
#if os(macOS)
    @NSApplicationDelegateAdaptor private var delegate: AppDelegate
    @AppStorage(Clash.theme) private var theme: Theme = .system
#else
    @UIApplicationDelegateAdaptor private var delegate: AppDelegate
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(VPNManager.shared)
                .environment(\.trafficFormatter, ClashTrafficFormatterKey.defaultValue)
                .environment(\.managedObjectContext, CoreDataStack.shared.container.viewContext)
#if os(macOS)
                .onChange(of: theme) { newValue in
                    newValue.applyAppearance()
                }
#else
                .environment(\.horizontalSizeClass, .compact)
#endif
        }
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .systemServices) {}
        }
#endif
    }
}
