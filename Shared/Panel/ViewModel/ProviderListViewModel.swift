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
    
    private let patchTrigger = CurrentValueSubject<Optional<Data>, Never>(.none)
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.patchTrigger
            .compactMap { $0 }
            .removeDuplicates()
            .compactMap { (data: Data) -> Optional<[String: PatchData]> in
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(ProviderListViewModel.formatter)
                    return try decoder.decode([String: PatchData].self, from: data)
                } catch {
                    return nil
                }
            }
            .print()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] patch in
                guard let self = self else {
                    return
                }
                self.patch(data: patch)
            }
            .store(in: &self.cancellables)
    }
        
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
        self.patchTrigger.send(try await controller.execute(command: .patchData))
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
