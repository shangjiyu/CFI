import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
                
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
        Theme(rawValue: UserDefaults.standard.integer(forKey: Clash.theme)).flatMap {
            $0.applyAppearance()
        }
        GEOIPDatabaseManager.copyGEOIPDatabase()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
