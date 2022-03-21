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

@MainActor class PanelInfoModel: ObservableObject {
        
    @Published var raw = RawConfig(proxies: [], groups: [])
    @Published var selection: [String: String] = [:]
    
    private let id: String
    
    init(id: String) {
        self.id = id
        let targetURL = Constant.homeDirectoryURL.appendingPathComponent("\(id)/config.yaml")
        do {
            self.raw = try YAMLDecoder().decode(from: try Data(contentsOf: targetURL))
        } catch {
            debugPrint(error.localizedDescription)
        }
        self.selection = UserDefaults.shared.dictionary(forKey: id) as? [String: String] ?? [:]
    }
    
    func selectedProxy(group: String) -> String? {
        self.selection[group]
    }
    
    func setSelected(proxy: String, group: String) {
        self.selection[group] = proxy
        UserDefaults.shared.setValue(self.selection, forKey: self.id)
        guard let controller = VPNManager.shared.controller else {
            return
        }
        Task(priority: .high) {
            do {
                try await controller.execute(command: .patchSelectGroup)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
