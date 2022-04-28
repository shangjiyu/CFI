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
                    if let delay = viewModel.delayMapping[proxy] {
                        Text(delay == 0 ? "超时" : "延迟: \(delay)毫秒")
                            .foregroundColor(delay == 0 ? Color.red : Color.secondary)
                            .font(.subheadline)
                    }
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
            .frame(width: 320, height: 320)
        }
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
