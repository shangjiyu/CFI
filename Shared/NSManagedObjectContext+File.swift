import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func importConfig(localFileURL url: URL) async throws {
        guard url.isFileURL else {
            return
        }
        let content = try String(contentsOf: url)
        let uuid = UUID()
        let directoryURL = Clash.homeDirectoryURL.appendingPathComponent("\(uuid.uuidString)")
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        let targetURL = directoryURL.appendingPathComponent("config.yaml")
        FileManager.default.createFile(atPath: targetURL.path, contents: content.data(using: .utf8), attributes: nil)
        let configuration = ClashConfig(context: self)
        configuration.uuid = uuid
        configuration.name = url.deletingPathExtension().lastPathComponent
        configuration.link = targetURL
        configuration.date = Date()
        
        try self.save()
    }
    
    func deleteClashConfig(_ config: ClashConfig) throws {
        self.delete(config)
        try self.save()
        guard let uuid = config.uuid else {
            return
        }
        try FileManager.default.removeItem(at: Clash.homeDirectoryURL.appendingPathComponent("\(uuid.uuidString)"))
    }
}
