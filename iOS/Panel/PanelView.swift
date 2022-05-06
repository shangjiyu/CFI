import SwiftUI

struct PanelView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    var body: some View {
        NavigationView {
            buildBody()
                .navigationBarTitle("策略组")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func buildBody() -> some View {
        if uuidString.isEmpty {
            Text("未选择配置")
        } else {
            if let controller = manager.controller {
                ProviderListContainerView()
                    .environmentObject(controller)
            } else {
                Text("VPN未连接")
            }
        }
    }
}

struct ProviderListContainerView: View {
    
    @EnvironmentObject private var controller: VPNController
    
    var body: some View {
        if controller.connectionStatus == .connected {
            ProviderListView()
        } else {
            Text("VPN未连接")
        }
    }
}

struct ProviderListView: View {
    
    @EnvironmentObject private var controller: VPNController
    @EnvironmentObject private var viewModel: ProviderListViewModel
    
    @AppStorage(Clash.tunnelMode, store: .shared) private var tunnelMode: Clash.TunnelMode = .rule
    
    var body: some View {
        Form {
            if tunnelMode == .global {
                Section {
                    buildCell(models: viewModel.globalProviderViewModels)
                }
            }
            Section {
                buildCell(models: viewModel.othersProviderViewModels)
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
    
    private func buildCell(models: [ProviderViewModel]) -> some View {
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

struct ProviderView: View {
    
    @EnvironmentObject private var viewModel: ProviderViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.name)
                Text("\(viewModel.proxies.count)代理 - \(viewModel.type.uppercased())")
                    .font(Font.subheadline)
                    .foregroundColor(Color.secondary)
            }
            Spacer()
            Text(viewModel.selected)
                .foregroundColor(Color.secondary)
        }
        .lineLimit(1)
        .padding(.vertical, 4)
    }
}

struct ProxyListView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var controller: VPNController
    @EnvironmentObject private var viewModel: ProviderViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("名称")
                        Spacer()
                        Text(viewModel.name)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("类型")
                        Spacer()
                        Text(viewModel.type.uppercased())
                            .foregroundColor(.secondary)
                    }
                }
                Section("包含") {
                    Picker(viewModel.name, selection: $viewModel.selected) {
                        ForEach(viewModel.proxies, id: \.name) { model in
                            ProxyView(selected: $viewModel.selected)
                                .environmentObject(model)
                        }
                    }
                    .onChange(of: viewModel.selected) { newValue in
                        viewModel.select(controller: controller, proxy: newValue)
                    }
                    .labelsHidden()
                    .pickerStyle(InlinePickerStyle())
                    .disabled(!viewModel.isSelectEnable)
                }
            }
            .navigationTitle(viewModel.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProxyView: View {
    
    @EnvironmentObject private var viewModel: ProxyViewModel
    
    @Binding var selected: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(viewModel.name)
            Text(viewModel.delay)
                .font(.subheadline)
                .foregroundColor(viewModel.delayTextColor)
        }
        .padding(.vertical, 8.0)
    }
}
