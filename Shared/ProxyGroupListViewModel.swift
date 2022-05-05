import Foundation
import Yams
import SwiftUI
import Combine

struct RawProxy: Decodable {
    let name: String
    let type: String
}

struct RawProxyGroup: Decodable {
    let name: String
    let type: String
    let proxies: [String]
}

struct RawConfig: Decodable {
    let proxies: [RawProxy]
    let groups: [RawProxyGroup]
    enum CodingKeys: String, CodingKey {
        case proxies    = "proxies"
        case groups     = "proxy-groups"
    }
}

struct ClashProxy: Decodable {
    
    struct History: Decodable {
        
        enum Delay {
            
            case low(UInt16), medium(UInt16), high(UInt16), timeout
            
            init(value: UInt16) {
                if value == 0 {
                    self = .timeout
                } else if value <= 200 {
                    self = .low(value)
                } else if value <= 600 {
                    self = .medium(value)
                } else {
                    self = .high(value)
                }
            }
        }
        
        let time: String
        let delay: Delay
        
        enum CodingKeys: String, CodingKey {
            case time = "time"
            case delay = "delay"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.time = try container.decode(String.self, forKey: .time)
            self.delay = History.Delay(value: try container.decode(UInt16.self, forKey: .delay))
        }
    }
    
    let name: String
    let type: String
    let selected: String
    let all: [String]
    let histories: [History]
    
    enum CodingKeys: String, CodingKey {
        case name       = "name"
        case type       = "type"
        case selected   = "now"
        case all        = "all"
        case histories  = "history"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(String.self, forKey: .type)
        do {
            self.selected = try container.decode(String.self, forKey: .selected)
        } catch {
            self.selected = ""
        }
        do {
            self.all = try container.decode([String].self, forKey: .all)
        } catch {
            self.all = []
        }
        do {
            self.histories = try container.decode([History].self, forKey: .histories)
        } catch {
            self.histories = []
        }
    }
}

struct Provider: Decodable {
    
    struct DelayHistory: Decodable {
        let time: String
        let delay: UInt16
    }
    
    struct Proxy: Decodable {
        let name: String
        let type: String
        let history: [DelayHistory]
    }
    
    let name: String
    let type: String
    let vehicleType: String
    let proxies: [Proxy]
}

enum Delay {
    
    case timeout
    case high(UInt16)
    case medium(UInt16)
    case low(UInt16)
    
    init(value: UInt16) {
        if value == 0 {
            self = .timeout
        } else if value <= 200 {
            self = .low(value)
        } else if value <= 600 {
            self = .medium(value)
        } else {
            self = .high(value)
        }
    }
    
    var displayString: String {
        switch self {
        case .timeout:
            return "超时"
        case .high(let v):
            return "\(v)ms"
        case .medium(let v):
            return "\(v)ms"
        case .low(let v):
            return "\(v)ms"
        }
    }
    
    var displayColor: Color {
        switch self {
        case .timeout:
            return .secondary
        case .high:
            return .red
        case .medium:
            return .yellow
        case .low:
            return .green
        }
    }
}

class ProxyGroupViewModel: ObservableObject {
    
    @Published var selectedProxy: String
    @Published var delayMapping: [String: Delay] = [:]
    
    let group: RawProxyGroup
    
    init(group: RawProxyGroup, selectedProxy proxy: String) {
        self.group = group
        self.selectedProxy = proxy
    }
    
    var isSelectable: Bool {
        self.group.type.uppercased() == "SELECT"
    }
    
    func loadProvider() async {
        
    }
}

class ProxyGroupListViewModel: ObservableObject {
    
    @Published private var mapping: [String: String] = [:]
    
    @Published var global: [ProxyGroupViewModel] = []
    @Published var others: [ProxyGroupViewModel] = []
    
    private var storeKey: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
        
    init() {
        Timer.publish(every: 1.0, on: .current, in: .common)
            .autoconnect()
            .compactMap { _ in VPNManager.shared.controller }
            .flatMap { controller in
                Future<Optional<Data>, Never> { promise in
                    Task {
                        do {
                            promise(.success(try await controller.execute(command: .proxies)))
                        } catch {
                            promise(.success(nil))
                        }
                    }
                }
            }
            .compactMap { $0 }
            .compactMap { data in
                do {
                    return try JSONDecoder().decode([String: ClashProxy].self, from: data)
                } catch {
                    return nil
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (mapping: [String: ClashProxy]) -> Void in
                guard let self = self else {
                    return
                }
                self.patchGroups(with: mapping)
            }
            .store(in: &self.cancellables)
    }
    
    private func patchGroups(with mapping: [String: ClashProxy]) {
        self.patch(groups: self.global, with: mapping)
        self.patch(groups: self.others, with: mapping)
    }
    
    private func patch(groups: [ProxyGroupViewModel], with mapping: [String: ClashProxy]) {
        for group in self.others {
            if let p = mapping[group.group.name] {
                group.selectedProxy = p.selected
            }
        }
    }
    
    func update(uuidString: String) {
        let key = "\(uuidString)-PatchGroup"
        guard key != self.storeKey else {
            return
        }
        self.storeKey = key
        let raw: RawConfig
        do {
            raw = try YAMLDecoder().decode(from: try Data(contentsOf: Clash.homeDirectoryURL.appendingPathComponent("\(uuidString)/config.yaml")))
        } catch {
            raw = RawConfig(proxies: [], groups: [])
        }
        let temp = UserDefaults.shared.dictionary(forKey: self.storeKey) as? [String: String] ?? [:]
        self.others = raw.groups.map { group in
            ProxyGroupViewModel(group: group, selectedProxy: temp[group.name] ?? group.proxies.first ?? "")
        }
        self.global = {
            var proxies: [String] = []
            proxies.append("DIRECT")
            proxies.append("REJECT")
            proxies.append(contentsOf: raw.proxies.map({ $0.name }))
            proxies.append(contentsOf: self.others.map({ $0.group.name }))
            let group = RawProxyGroup(name: "GLOBAL", type: "select", proxies: proxies)
            let viewModel = ProxyGroupViewModel(
                group: group,
                selectedProxy: temp[group.name] ?? group.proxies.first ?? ""
            )
            return [viewModel]
        }()
        self.mapping = temp
    }
    
    func setSelected(proxy: String, groupViewModel: ProxyGroupViewModel) {
//        self.mapping[groupViewModel.group.name] = proxy
//        UserDefaults.shared.setValue(self.mapping, forKey: self.storeKey)
//        Task(priority: .high) {
//            guard let controller = VPNManager.shared.controller else {
//                return
//            }
//            do {
//                try await controller.execute(command: .setSelectGroup)
//            } catch {
//                debugPrint(error.localizedDescription)
//            }
//        }
    }
}
