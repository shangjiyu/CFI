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
                            if selected == viewModel.name {
                                Circle()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.green)
                                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 0, trailing: 0))
                            }
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
#else
        HStack(spacing: 12) {
            Text(viewModel.name)
            Text(viewModel.delay)
                .font(.subheadline)
                .foregroundColor(viewModel.delayTextColor)
        }
        .padding(.vertical, 8.0)
#endif
    }
}
