import SwiftUI

struct ProxyView: View {
    
    @EnvironmentObject private var viewModel: ProxyViewModel
    
    @Binding var selected: String
    
    var body: some View {
        GroupBox {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(viewModel.type.uppercased())
                            .font(.system(size: 8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 4).stroke(.tint))
                        Spacer()
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(selected == viewModel.name ? .green : .clear)
                    }
                    Text(viewModel.name)
                        .foregroundColor(.secondary)
                    Text(viewModel.delay)
                        .font(.subheadline)
                        .foregroundColor(viewModel.delayTextColor)
                }
                .lineLimit(1)
                Spacer()
            }
            .padding(8)
        }
    }
}
