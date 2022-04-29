import SwiftUI

struct ProxyGroupDetailView: View {
    
    @EnvironmentObject private var listViewModel: ProxyGroupListViewModel
    @EnvironmentObject private var viewModel: ProxyGroupViewModel
        
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("名称")
                    Spacer()
                    Text(viewModel.group.name)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("类型")
                    Spacer()
                    Text(viewModel.group.type.uppercased())
                        .foregroundColor(.secondary)
                }
            }
            Section("包含") {
                Picker(viewModel.group.name, selection: viewModel.isSelectable ? $viewModel.selectedProxy : .constant("")) {
                    ForEach(viewModel.group.proxies, id: \.self) { proxy in
                        HStack(spacing: 12) {
                            Text(proxy)
                            Text(viewModel.delayMapping[proxy]?.displayString ?? "")
                                .foregroundColor(viewModel.delayMapping[proxy]?.displayColor ?? .clear)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 8.0)
                    }
                }
                .onChange(of: viewModel.selectedProxy) { newValue in
                    guard viewModel.isSelectable else {
                        return
                    }
                    listViewModel.setSelected(proxy: newValue, groupViewModel: viewModel)
                }
                .labelsHidden()
                .pickerStyle(InlinePickerStyle())
                .disabled(!viewModel.isSelectable)
            }
        }
        .onAppear {
            loadProvider()
        }
        .onReceive(Timer.publish(every: 1.0, on: .current, in: .common).autoconnect()) { _ in
            loadProvider()
        }
        .navigationTitle(viewModel.group.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func loadProvider() {
        Task(priority: .medium) {
            await viewModel.loadProvider()
        }
    }
}
