import SwiftUI

struct ProviderView: View {
    
    @EnvironmentObject private var viewModel: ProviderViewModel
    
    var body: some View {
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
    }
}
