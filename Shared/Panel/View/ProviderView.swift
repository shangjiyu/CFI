import SwiftUI

struct ProviderView: View {
    
    @EnvironmentObject private var viewModel: ProviderViewModel
    
    var body: some View {
#if os(macOS)
        GroupBox {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.name)
                        .fontWeight(.medium)
                    Text(viewModel.type.uppercased())
                        .font(.system(size: 8))
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().stroke(lineWidth: 1.0))
                        .foregroundColor(.accentColor)
                    Text(viewModel.selected)
                }
                .lineLimit(1)
                Spacer()
            }
            .padding(8)
        }
#else
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.name)
                Text("\(viewModel.proxies.count)代理 - \(viewModel.type.uppercased())")
                    .font(Font.subheadline)
                    .foregroundColor(Color.secondary)
            }
            Spacer()
            Text(viewModel.selected)
                .foregroundColor(Color.secondary)
        }
        .lineLimit(1)
        .padding(.vertical, 4)
#endif
    }
}
