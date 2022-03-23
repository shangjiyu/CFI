import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        self.copyCountryDB()
    }
    
    private func copyCountryDB() {
        let dbFileName = "Country"
        let dbFileExtension = "mmdb"
        let dbURL = Constant.homeDirectoryURL.appendingPathComponent("\(dbFileName).\(dbFileExtension)")
        guard !FileManager.default.fileExists(atPath: dbURL.path) else {
            return
        }
        guard let local = Bundle.main.url(forResource: dbFileName, withExtension: dbFileExtension) else {
            return
        }
        do {
            try FileManager.default.copyItem(at: local, to: dbURL)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
