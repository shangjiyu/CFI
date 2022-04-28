import SwiftUI

struct ProxyGroupListView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var viewModel: ProxyGroupListViewModel
    
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 3
    )
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.globalGroupViewModels + viewModel.groupViewModels, id: \.group.name) { model in
                    ModalPresentationLink {
                        ProxyGroupDetailView()
                            .environmentObject(viewModel)
                            .environmentObject(model)
                    } label: {
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
                                Text(model.isSelectable ? model.selectedProxy : "")
                            }
                            .lineLimit(1)
                            Spacer()
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.7))
                        )
                    }
                }
            }
            .padding()
        }
    }
}
