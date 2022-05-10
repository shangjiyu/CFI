import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func importConfig(url: URL, data: Data) async throws {
        let uuid = UUID()
        let directoryURL = Clash.homeDirectoryURL.appendingPathComponent("\(uuid.uuidString)")
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        let targetURL = directoryURL.appendingPathComponent("config.yaml")
        FileManager.default.createFile(atPath: targetURL.path, contents: data, attributes: nil)
        let configuration = ClashConfig(context: self)
        configuration.uuid = uuid
        configuration.name = url.deletingPathExtension().lastPathComponent
        configuration.link = url
        configuration.date = Date()
        
        try self.save()
    }
    
    func deleteClashConfig(_ config: ClashConfig) throws {
        self.delete(config)
        try self.save()
        guard let uuid = config.uuid else {
            return
        }
        UserDefaults.shared.set(nil, forKey: "\(uuid.uuidString)-PatchGroup")
        try FileManager.default.removeItem(at: Clash.homeDirectoryURL.appendingPathComponent("\(uuid.uuidString)"))
    }
}
