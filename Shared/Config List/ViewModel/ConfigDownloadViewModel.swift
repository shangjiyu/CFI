import SwiftUI

class ConfigDownloadViewModel: ObservableObject {
    
    @Published var url: String = ""
    @Published var isProcessing: Bool = false
    
    func download() async throws -> (URL, Data) {
        guard let url = URL(string: url) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL不合法"])
        }
        await MainActor.run {
            isProcessing = true
        }
        let result: Result<Data, Error>
        do {
            result = .success(try await URLSession.shared.data(from: url, delegate: nil).0)
        } catch {
            result = .failure(error)
        }
        await MainActor.run {
            isProcessing = false
        }
        switch result {
        case .success(let data):
            return (url, data)
        case .failure(let error):
            throw error
        }
    }
}
