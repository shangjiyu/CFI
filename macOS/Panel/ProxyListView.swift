import SwiftUI

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
                        ProxyView(selected: $viewModel.selected)
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
