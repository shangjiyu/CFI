import SwiftUI

struct SelectableGroupBoxStyle: GroupBoxStyle {
    
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        GroupBox(configuration)
            .background(
                RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 2)
                    .foregroundColor(isSelected ? .accentColor : .clear)
            )
    }
}
