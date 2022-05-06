import SwiftUI

struct ProviderListView: View {
    
    @EnvironmentObject private var controller: VPNController
    @EnvironmentObject private var viewModel: ProviderListViewModel
    
    @AppStorage(Clash.tunnelMode, store: .shared) private var tunnelMode: Clash.TunnelMode = .rule
    
#if os(macOS)
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 3
    )
#endif
    
    var body: some View {
        buildBodyContainer()
            .task {
                do {
                    try await viewModel.fetchProxyData(controller: controller)
                    try await viewModel.patchProxyData(controller: controller)
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }
            .onReceive(Timer.publish(every: 1.0, on: .current, in: .common).autoconnect()) { _ in
                Task {
                    do {
                        try await viewModel.patchProxyData(controller: controller)
                    } catch {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
    }
    
    @ViewBuilder
    private func buildBodyContainer() -> some View {
#if os(macOS)
        ScrollView(.vertical, showsIndicators: false) {
            buildBody()
        }
#else
        Form {
            buildBody()
        }
#endif
    }
    
    @ViewBuilder
    private func buildBody() -> some View {
        if tunnelMode == .global {
            buildSection(models: viewModel.globalProviderViewModels)
        }
        buildSection(models: viewModel.othersProviderViewModels)
    }
    
    private func buildSection(models: [ProviderViewModel]) -> some View {
        Section {
#if os(macOS)
            LazyVGrid(columns: columns) {
                buildCells(models: models)
            }
            .padding()
#else
            buildCells(models: models)
#endif
        }
    }
    
    private func buildCells(models: [ProviderViewModel]) -> some View {
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

