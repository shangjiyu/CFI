import SwiftUI

struct PlaceholderView: View {
    
    let placeholder: String
    
    var body: some View {
        Text(placeholder)
            .foregroundColor(.secondary)
    }
}
