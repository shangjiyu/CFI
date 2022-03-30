import SwiftUI

struct TrafficView: View {
    
    @Environment(\.trafficFormatter) private var formatter: NumberFormatter
    
    @AppStorage(Clash.Traffic.up.rawValue, store: .shared) private var up: Double = 0
    @AppStorage(Clash.Traffic.down.rawValue, store: .shared) private var down: Double = 0
        
    var body: some View {
        VStack(spacing: 12) {
            buildElementView(traffic: .up)
            buildElementView(traffic: .down)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.8))
        )
    }
    
    private func buildElementView(traffic: Clash.Traffic) -> some View {
        HStack {
            Image(systemName: traffic.imageName)
                .font(.title3)
            Text(traffic.title)
            Spacer()
            Text(formatter.string(from: NSNumber(value: traffic == .up ? up : down)) ?? "-")
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
    }
}
