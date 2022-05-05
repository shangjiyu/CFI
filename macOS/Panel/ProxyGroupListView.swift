import SwiftUI

struct ProxyGroupListView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var viewModel: ProxyGroupListViewModel
    
    @AppStorage(Clash.tunnelMode, store: .shared) private var tunnelMode: Clash.TunnelMode = .rule
    
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 3
    )
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if tunnelMode == .global {
                Section {
                    buildGride(models: viewModel.global)
                        .padding()
                }
            }
            Section {
                buildGride(models: viewModel.others)
                    .padding()
            }
        }
    }
    
    private func buildGride(models: [ProxyGroupViewModel]) -> some View {
        LazyVGrid(columns: columns) {
            ForEach(models, id: \.group.name) { model in
                ModalPresentationLink {
                    ProxyGroupDetailView()
                        .environmentObject(viewModel)
                        .environmentObject(model)
                } label: {
                    GroupBox {
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(model.group.name)
                                    .fontWeight(.medium)
                                Text(model.group.type.uppercased())
                                    .font(.system(size: 8))
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().stroke(lineWidth: 1.0))
                                    .foregroundColor(.accentColor)
                                Text(model.selectedProxy)
                            }
                            .lineLimit(1)
                            Spacer()
                        }
                        .padding(8)
                    }
                }
            }
        }
    }
}
