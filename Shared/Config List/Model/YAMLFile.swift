import SwiftUI
import UniformTypeIdentifiers

struct YAMLFile: FileDocument {
    
    static let readableContentTypes: [UTType] = [.yaml]
    
    init(configuration: ReadConfiguration) throws {
        fatalError()
    }
    
    private let fileURL: URL
    
    init?(exportItems: [Any]?) {
        guard let items = exportItems, let fileURL = items.first as? URL else {
            return nil
        }
        self.fileURL = fileURL
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        try FileWrapper(url: self.fileURL, options: [])
    }
}
