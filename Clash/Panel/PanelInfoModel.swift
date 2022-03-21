import SwiftUI
import CommonKit
import Yams

struct RawProxy: Decodable {
    let name: String
    let type: String
}

struct RawProxyGroup: Decodable {
    let name: String
    let type: String
    let proxies: [String]
}

extension RawProxyGroup {
    
    var isSelectEnable: Bool {
        self.type.uppercased() == "SELECT"
    }
}

struct RawConfig: Decodable {
    let proxies: [RawProxy]
    let groups: [RawProxyGroup]
    enum CodingKeys: String, CodingKey {
        case proxies    = "proxies"
        case groups     = "proxy-groups"
    }
}

class PanelInfoModel: ObservableObject {
    
    private let config: ClashConfig
    
    @Published var raw = RawConfig(proxies: [], groups: [])
    
    init(config: ClashConfig) {
        self.config = config
        guard let uuid = self.config.uuid else {
            return
        }
        let targetURL = Constant.homeDirectoryURL.appendingPathComponent("\(uuid.uuidString)/config.yaml")
        do {
            self.raw = try YAMLDecoder().decode(from: try Data(contentsOf: targetURL))
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
