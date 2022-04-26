import SwiftUI

struct ProxyGroupListView: View {
    
    @EnvironmentObject var viewModel: ProxyGroupListViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            List(viewModel.globalGroupViewModels + viewModel.groupViewModels, id: \.self.group.name) { model in
                self.buildCell(model: model)
            }
            .listStyle(.sidebar)
        }
    }
    
    private func buildCell(model: ProxyGroupViewModel) -> some View {
        DisclosureGroup {
            ForEach(model.group.proxies, id: \.self) { proxy in
                HStack(spacing: 0) {
                    Text(proxy)
                        .foregroundColor(model.isSelectable && model.selectedProxy == proxy ? .accentColor : .primary)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard model.isSelectable else {
                        return
                    }
                    viewModel.setSelected(proxy: proxy, groupViewModel: model)
                }
            }
        } label: {
            HStack {
                Text(model.group.name)
                    .fontWeight(.bold)
                Spacer()
                Text(model.isSelectable ? model.selectedProxy : "")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8.0)
        }
    }
}
