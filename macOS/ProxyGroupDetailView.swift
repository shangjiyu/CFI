import SwiftUI

struct ProxyGroupDetailView: View {
    
    @EnvironmentObject var viewModel: ProxyGroupListViewModel
    
    private let colums: [GridItem] = [GridItem(.adaptive(minimum: 120))]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: self.colums) {
                if let model = viewModel.selectedGroupViewModel {
                    ForEach(model.group.proxies, id: \.self) { proxy in
                        HStack(spacing: 0) {
                            Text(proxy)
                                .lineLimit(1)
                            Spacer(minLength: 0)
                        }
                        .foregroundColor(.white)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill((model.selectedProxy == proxy && model.isSelectable) ? Color.accentColor : Color.gray.opacity(0.5))
                        )
                        .onTapGesture {
                            guard model.isSelectable else {
                                return
                            }
                            viewModel.setSelected(proxy: proxy, groupViewModel: model)
                        }
                    }
                }
            }
            .padding()
        }
    }
}
