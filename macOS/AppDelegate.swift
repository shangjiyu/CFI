import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
            
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
        GEOIPDatabaseManager.copyGEOIPDatabase()
    }
}
