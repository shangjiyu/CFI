import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let bar = NSStatusBar()
    private var statusItem: NSStatusItem?
            
    func applicationDidFinishLaunching(_ notification: Notification) {
        let statusItem = self.bar.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem.button else {
            return
        }
        button.image = NSImage(named: "logo")
        let item = NSMenuItem()
        item.view = {
            let contentView = ContentView()
                .environmentObject(VPNManager.shared)
                .environment(\.trafficFormatter, ClashTrafficFormatterKey.defaultValue)
                .environment(\.managedObjectContext, CoreDataStack.shared.container.viewContext)
            let view = NSHostingView(rootView: contentView)
            view.frame = NSRect(x: 0, y: 0, width: 240, height: 400)
            return view
        }()
        let menu = NSMenu()
        menu.addItem(item)
        statusItem.menu = menu
        self.statusItem = statusItem
        
        GEOIPDatabaseManager.copyGEOIPDatabase()
    }
}
