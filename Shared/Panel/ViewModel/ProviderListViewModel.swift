import Foundation
import Combine

class ProviderListViewModel: ObservableObject {
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: NSCalendar.Identifier.ISO8601.rawValue)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        return formatter
    }()
    
    private var proxyViewModels: [String: ProxyViewModel] = [:]
    
    @Published var globalProviderViewModels: [ProviderViewModel] = []
    @Published var othersProviderViewModels: [ProviderViewModel] = []
        
    func fetchProxyData(controller: VPNController) async throws {
        guard let data = try await controller.execute(command: .mergedProxyData) else {
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(ProviderListViewModel.formatter)
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
            result[pair.key] = ProxyViewModel(name: pair.value.name, type: pair.value.type, histories: pair.value.history)
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
    
    func patchProxyData(controller: VPNController) async throws {
        guard let data = try await controller.execute(command: .patchData) else {
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(ProviderListViewModel.formatter)
        let patch = try decoder.decode([String: PatchData].self, from: data)
        await MainActor.run { self.patch(data: patch) }
    }
    
    private func patch(data: [String: PatchData]) {
        self.globalProviderViewModels.forEach { vm in
            vm.selected = data[vm.name]?.current ?? ""
        }
        self.othersProviderViewModels.forEach { vm in
            vm.selected = data[vm.name]?.current ?? ""
        }
        self.proxyViewModels.forEach { pair in
            pair.value.histories = data[pair.key]?.histories ?? []
        }
    }
}
