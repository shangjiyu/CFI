import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    
    @AppStorage(Clash.theme) private var theme: Theme = .system
            
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
        theme.applyAppearance()
        GEOIPDatabaseManager.copyGEOIPDatabase()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
