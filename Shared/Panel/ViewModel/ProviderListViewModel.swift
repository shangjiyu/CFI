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
    
    private var cancellables: Set<AnyCancellable> = []
    
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
    
    func update(with controller: VPNController) {
        self.cancellables = []
        Timer.publish(every: 1.0, on: .current, in: .common)
            .autoconnect()
            .flatMap { _ in
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
            .removeDuplicates()
            .map { (data) -> Optional<[String: MergedProxyData.Proxy]> in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(ProviderListViewModel.formatter)
                do {
                    return try decoder.decode([String: MergedProxyData.Proxy].self, from: data)
                } catch {
                    debugPrint(error.localizedDescription)
                    return nil
                }
            }
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] patch in
                guard let self = self else {
                    return
                }
                self.patchViewModels(patch: patch)
            }
            .store(in: &self.cancellables)
    }
    
    private func patchViewModels(patch: [String: MergedProxyData.Proxy]) {
        self.globalProviderViewModels.forEach { vm in
            vm.selected = patch[vm.name]?.now ?? ""
        }
        self.othersProviderViewModels.forEach { vm in
            vm.selected = patch[vm.name]?.now ?? ""
        }
        self.proxyViewModels.forEach { pair in
            pair.value.histories = patch[pair.key]?.history ?? []
        }
    }
}
