import SwiftUI

struct ProxyGroupDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var listViewModel: ProxyGroupListViewModel
    @EnvironmentObject private var viewModel: ProxyGroupViewModel
    
    private var selection: Binding<String?> {
        return Binding {
            viewModel.selectedProxy
        } set: { new in
            viewModel.selectedProxy = new ?? ""
        }
    }
            
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Text("关闭")
                }
                .foregroundColor(.accentColor)
                .buttonStyle(.plain)
                Spacer()
            }
            .padding()
            
            Divider()
            
            List(viewModel.group.proxies, id: \.self, selection: viewModel.isSelectable ? selection : nil) { proxy in
                HStack {
                    Text(proxy)
                    Spacer()
                    Text(viewModel.delayMapping[proxy]?.displayString ?? "")
                        .foregroundColor(viewModel.delayMapping[proxy]?.displayColor ?? .clear)
                        .font(.subheadline)
                }
                .padding(.vertical, 8.0)
            }
            .listStyle(.sidebar)
            .onChange(of: viewModel.selectedProxy) { newValue in
                guard viewModel.isSelectable else {
                    return
                }
                listViewModel.setSelected(proxy: newValue, groupViewModel: viewModel)
            }
        }
        .frame(width: 320, height: 480)
        .onAppear {
            loadProvider()
        }
        .onReceive(Timer.publish(every: 1.0, on: .current, in: .common).autoconnect()) { _ in
            loadProvider()
        }
    }
    
    private func loadProvider() {
        Task(priority: .medium) {
            await viewModel.loadProvider()
        }
    }
}
