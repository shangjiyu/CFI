import SwiftUI

struct ProxyView: View {
    
    @EnvironmentObject private var viewModel: ProxyViewModel
    
    @Binding var selected: String
    
    var body: some View {
#if os(macOS)
        GroupBox {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack(alignment: .top, spacing: 0) {
                            Text(viewModel.name)
                            Text("\n")
                            Spacer()
                        }
                        .lineLimit(2)
                    }
                    Text(viewModel.delay)
                        .font(.subheadline)
                        .foregroundColor(viewModel.delayTextColor)
                }
                .lineLimit(1)
                Spacer()
            }
            .padding(8)
        }
        .groupBoxStyle(SelectableGroupBoxStyle(isSelected: selected == viewModel.name))
#else
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.name)
            if viewModel.isURLTestEnable {
                Text(viewModel.delay)
                    .font(.subheadline)
                    .foregroundColor(viewModel.delayTextColor)
            }
        }
        .padding(.vertical, 8.0)
#endif
    }
}
