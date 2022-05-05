import SwiftUI
import Combine

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
    let type: String
    @Published var histories: [DelayHistory]
    
    init(name: String, type: String, histories: [DelayHistory]) {
        self.name = name
        self.type = type
        self.histories = histories
    }
    
    var delay: String {
        guard let last = histories.first else {
            return ""
        }
        if last.delay == 0 {
            return "超时"
        } else {
            return "\(last.delay)ms"
        }
    }
    
    var delayTextColor: Color {
        guard let last = histories.first else {
            return .clear
        }
        if last.delay == 0 {
            return .secondary
        } else if last.delay <= 300 {
            return .green
        } else if last.delay <= 600 {
            return .yellow
        } else {
            return .red
        }
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
    
    func select(controller: VPNController, proxy: ProxyViewModel) {
        guard let uuid = UserDefaults.shared.string(forKey: Clash.currentConfigUUID) else {
            return
        }
        let key = "\(uuid)-PatchGroup"
        guard var mapping = UserDefaults.shared.value(forKey: key) as? [String: String] else {
            return
        }
        mapping[self.name] = proxy.name
        UserDefaults.shared.set(mapping, forKey: key)
        Task(priority: .high) {
            do {
                try await controller.execute(command: .setSelectGroup)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

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
    
    func beginUpdating(controller: VPNController) {
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
                viewModel.beginUpdating(controller: controller)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func buildGride(models: [ProviderViewModel]) -> some View {
        LazyVGrid(columns: columns) {
            ForEach(models, id: \.name) { model in
                ModalPresentationLink {
                    ProxyListView()
                } label: {
                    ProviderView()
                }
                .environmentObject(model)
            }
        }
    }
}

struct ProviderView: View {
    
    @EnvironmentObject private var viewModel: ProviderViewModel
    
    var body: some View {
        GroupBox {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.name)
                        .fontWeight(.medium)
                    Text(viewModel.type.uppercased())
                        .font(.system(size: 8))
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().stroke(lineWidth: 1.0))
                        .foregroundColor(.accentColor)
                    Text(viewModel.selected)
                }
                .lineLimit(1)
                Spacer()
            }
            .padding(8)
        }
    }
}

struct ProxyListView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var controller: VPNController
    @EnvironmentObject private var viewModel: ProviderViewModel
    
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 3
    )
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Text("关闭")
                }
                Spacer()
            }
            .foregroundColor(.accentColor)
            .buttonStyle(.plain)
            .padding()
            
            ScrollView(.vertical, showsIndicators: true) {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.proxies, id: \.name) { model in
                        _ProxyView(selected: $viewModel.selected)
                            .environmentObject(model)
                            .onTapGesture {
                                viewModel.select(controller: controller, proxy: model)
                            }
                    }
                }
                .padding()
            }
        }
        .frame(width: 540, height: 480)
    }
}

struct _ProxyView: View {
    
    @EnvironmentObject private var viewModel: ProxyViewModel
    
    @Binding var selected: String
    
    var body: some View {
        GroupBox {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(viewModel.type.uppercased())
                            .font(.system(size: 8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 4).stroke(.tint))
                        Spacer()
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(selected == viewModel.name ? .green : .clear)
                    }
                    Text(viewModel.name)
                        .foregroundColor(.secondary)
                    Text(viewModel.delay)
                        .font(.subheadline)
                        .foregroundColor(viewModel.delayTextColor)
                }
                .lineLimit(1)
                Spacer()
            }
            .padding(8)
        }
    }
}
