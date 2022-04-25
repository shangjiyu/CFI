import SwiftUI

struct ProxyGroupListView: View {
    
    @EnvironmentObject var viewModel: ProxyGroupListViewModel
    
    private let colums: [GridItem] = [
        GridItem(.flexible(), spacing: 10, alignment: .center),
        GridItem(.flexible(), spacing: 10, alignment: .center),
        GridItem(.flexible(), spacing: 10, alignment: .center),
        GridItem(.flexible(), spacing: 10, alignment: .center)
    ]
        
    var body: some View {

        VStack(spacing: 0) {
            Divider()
            List(viewModel.groupViewModels, id: \.self.group.name) { model in
                DisclosureGroup {
                    LazyVGrid(columns: colums) {
                        ForEach(model.group.proxies, id: \.self) { proxy in
                            HStack {
                                Text(proxy)
                                Spacer()
                            }
                            .padding()
                            .background(.red)
                        }
                    }
                } label: {
                    HStack {
                        Text(model.group.name)
                        Spacer()
                        Text(model.isSelectable ? model.selectedProxy : "")
                    }
                    .padding(.vertical, 8.0)
                }
            }
            .listStyle(.sidebar)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Text("策略组")
            }
        }
    }
}
