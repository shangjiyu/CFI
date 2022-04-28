import SwiftUI

struct TrafficView: View {
    
    @Environment(\.trafficFormatter) private var formatter: NumberFormatter
    
    @AppStorage(Clash.Traffic.up.rawValue, store: .shared) private var up: Double = 0
    @AppStorage(Clash.Traffic.down.rawValue, store: .shared) private var down: Double = 0
        
    var body: some View {
        HStack(spacing: 32) {
            buildElementView(traffic: .up)
            buildElementView(traffic: .down)
        }
    }
    
    private func buildElementView(traffic: Clash.Traffic) -> some View {
        HStack {
            Image(systemName: traffic.imageName)
            Spacer()
            Text(formatter.string(from: NSNumber(value: traffic == .up ? up : down)) ?? "-")
        }
    }
}
