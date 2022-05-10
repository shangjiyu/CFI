import SwiftUI

class FileDownloadViewModel: ObservableObject {
    
    @Published var url: String = ""
    @Published var isProcessing: Bool = false
    
    func download() async throws -> (URL, URL) {
        guard let url = URL(string: url) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL不合法"])
        }
        await MainActor.run {
            isProcessing = true
        }
        let destinationURL = URL(
            fileURLWithPath: "\(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0])/\(UUID().uuidString).yaml"
        )
        let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
        print(data)
        try data.write(to: destinationURL)
        await MainActor.run {
            isProcessing = false
        }
        return (destinationURL, url)
    }
}
