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
                        VStack(alignment: .leading, spacing: 4) {
                            Text(proxy)
                            if let delay = viewModel.delayMapping[proxy] {
                                Text(delay == 0 ? "超时" : "延迟: \(delay)毫秒")
                                    .foregroundColor(delay == 0 ? Color.red : Color.secondary)
                                    .font(.subheadline)
                            }
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
        .task {
            await viewModel.loadProvider()
        }
        .navigationTitle(viewModel.group.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
