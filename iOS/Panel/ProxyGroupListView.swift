import SwiftUI

struct ProxyGroupListView: View {
    
    @EnvironmentObject private var viewModel: ProxyGroupListViewModel
    
    var body: some View {
        Form {
            Section("全局策略组") {
                ForEach(viewModel.globalGroupViewModels, id: \.group.name, content: buildCell(model:))
            }
            Section("策略组") {
                ForEach(viewModel.groupViewModels, id: \.group.name, content: buildCell(model:))
            }
        }
    }
    
    private func buildCell(model: ProxyGroupViewModel) -> some View {
        NavigationLink {
            ProxyGroupDetailView()
                .environmentObject(viewModel)
                .environmentObject(model)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.group.name)
                    Text("\(model.group.proxies.count)代理 - \(model.group.type.uppercased())")
                        .font(Font.subheadline)
                        .foregroundColor(Color.secondary)
                }
                Spacer()
                Text(model.isSelectable ? model.selectedProxy : "")
                    .foregroundColor(Color.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}
