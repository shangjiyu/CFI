import SwiftUI

struct ProxyGroupDetailView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
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
                        Text(proxy)
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
        .navigationTitle(viewModel.group.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard viewModel.isURLTestGroup else {
                return
            }
            guard let controller = manager.controller else {
                return
            }
            Task {
                for name in self.viewModel.group.proxies {
                    do {
                        let data = try await controller.execute(command: .fetchProxyDelay(name, "http://www.gstatic.com/generate_204", 3000))
                        if let data = data {
                            print(String(data: data, encoding: .utf8)!)
                        }
                    } catch {
                        NSLog(error.localizedDescription)
                    }
                    print("--------------")
                }
            }
        }
    }
}
