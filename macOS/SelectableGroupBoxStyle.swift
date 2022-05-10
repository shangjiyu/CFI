import SwiftUI

struct SelectableGroupBoxStyle: GroupBoxStyle {
    
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        GroupBox(configuration)
            .background(
                RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 2)
                    .foregroundColor(isSelected ? .green : .clear)
            )
    }
}
