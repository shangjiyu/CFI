import SwiftUI

struct PanelView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
        
    @StateObject var viewModel = ProxyGroupListViewModel()
    
    var body: some View {
        if uuidString.isEmpty {
            PlaceholderView(placeholder: "未选择配置")
        } else {
            if let controller = manager.controller {
                ProxyView()
                    .environmentObject(controller)
            } else {
                PlaceholderView(placeholder: "VPN未连接")
            }
        }
    }
}

struct ProxyView: View {
    
    @EnvironmentObject private var controller: VPNController
    
    var body: some View {
        if controller.connectionStatus == .connected {
            ProviderListView()
        } else {
            PlaceholderView(placeholder: "VPN未连接")
        }
    }
}

struct PlaceholderView: View {
    
    let placeholder: String
    
    var body: some View {
        Text(placeholder)
            .foregroundColor(.secondary)
    }
}

struct DelayHistory: Decodable {
    let time: Date
    let delay: UInt16
}

struct MergedProxyData: Decodable {
    
    struct Proxy: Decodable {
        let name: String
        let type: String
        let now: String?
        let all: [String]?
        let history: [DelayHistory]
    }
    
    struct Provider: Decodable {
        let proxies: [Proxy]
        let name: String
        let type: String
        let vehicleType: String
    }
    
    let proxies: [String: Proxy]
    let providers: [String: Provider]
}

class ProxyViewModel: ObservableObject {
    
    let name: String
    @Published var histories: [DelayHistory]
    
    init(name: String, histories: [DelayHistory]) {
        self.name = name
        self.histories = histories
    }
}

class ProviderViewModel: ObservableObject {
    
    let name: String
    let type: String
    let proxies: [ProxyViewModel]
    @Published var selected: String
    
    init(name: String, type: String, selected: String, proxies: [ProxyViewModel]) {
        self.name = name
        self.type = type
        self.selected = selected
        self.proxies = proxies
    }
}

class ProviderListViewModel: ObservableObject {
    
    private var proxyViewModels: [String: ProxyViewModel] = [:]
    
    @Published var globalProviderViewModels: [ProviderViewModel] = []
    @Published var othersProviderViewModels: [ProviderViewModel] = []
    
    func fetchProxyData(controller: VPNController) async throws {
        guard let data = try await controller.execute(command: .mergedProxyData) else {
            return
        }
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: NSCalendar.Identifier.ISO8601.rawValue)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        let model = try decoder.decode(MergedProxyData.self, from: data)
        guard let global = model.proxies["GLOBAL"], let proxies = global.all, !proxies.isEmpty else {
            return
        }
        let orderedProviders = proxies.reduce(into: [MergedProxyData.Provider]()) { result, proxy in
            guard let provider = model.providers[proxy] else {
                return
            }
            result.append(provider)
        }
        
        let pVMs = model.proxies.reduce(into: [String: ProxyViewModel]()) { result, pair in
            result[pair.key] = ProxyViewModel(name: pair.value.name, histories: pair.value.history)
        }
        
        let oVMs: [ProviderViewModel] = orderedProviders.map { reval in
            ProviderViewModel(
                name: reval.name,
                type: model.proxies[reval.name]?.type ?? "",
                selected: model.proxies[reval.name]?.now ?? "",
                proxies: reval.proxies.compactMap { reval in
                    pVMs[reval.name]
                }
            )
        }
        let gVM = ProviderViewModel(
            name: "GLOBAL",
            type: "Selector",
            selected: model.proxies["GLOBAL"]?.now ?? "",
            proxies: proxies.compactMap { reval in
                pVMs[reval]
            }
        )
        await MainActor.run {
            self.proxyViewModels = pVMs
            self.globalProviderViewModels = [gVM]
            self.othersProviderViewModels = oVMs
        }
    }
}


struct ProviderListView: View {
    
    @EnvironmentObject private var controller: VPNController
    
    @AppStorage(Clash.tunnelMode, store: .shared) private var tunnelMode: Clash.TunnelMode = .rule
    
    @StateObject private var viewModel = ProviderListViewModel()
    
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 3
    )
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if tunnelMode == .global {
                Section {
                    buildGride(models: viewModel.globalProviderViewModels)
                        .padding()
                }
            }
            Section {
                buildGride(models: viewModel.othersProviderViewModels)
                    .padding()
            }
        }
        .task {
            do {
                try await viewModel.fetchProxyData(controller: controller)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func buildGride(models: [ProviderViewModel]) -> some View {
        LazyVGrid(columns: columns) {
            ForEach(models, id: \.name) { model in
                GroupBox {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(model.name)
                                .fontWeight(.medium)
                            Text(model.type.uppercased())
                                .font(.system(size: 8))
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().stroke(lineWidth: 1.0))
                                .foregroundColor(.accentColor)
                            Text(model.selected)
                        }
                        .lineLimit(1)
                        Spacer()
                    }
                    .padding(8)
                }
            }
        }
    }
}
