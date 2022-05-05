import SwiftUI

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
                viewModel.update(with: controller)
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

