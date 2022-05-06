import SwiftUI

struct ProviderListView: View {
    
    @EnvironmentObject private var controller: VPNController
    @EnvironmentObject private var viewModel: ProviderListViewModel
    
    @AppStorage(Clash.tunnelMode, store: .shared) private var tunnelMode: Clash.TunnelMode = .rule
    
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

