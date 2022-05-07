import SwiftUI

struct TrafficView: View {
    
    @Environment(\.trafficFormatter) private var formatter: NumberFormatter
    
    @AppStorage(Clash.Traffic.up.rawValue, store: .shared) private var up: Double = 0
    @AppStorage(Clash.Traffic.down.rawValue, store: .shared) private var down: Double = 0
        
    var body: some View {
#if os(macOS)
        HStack(spacing: 32) {
            buildElementView(traffic: .up)
            buildElementView(traffic: .down)
        }
#else
        buildElementView(traffic: .up)
        buildElementView(traffic: .down)
#endif
    }
    
    private func buildElementView(traffic: Clash.Traffic) -> some View {
        HStack {
#if os(macOS)
            Image(systemName: traffic.imageName)
#else
            Label(traffic.title, systemImage: traffic.imageName)
#endif
            Spacer()
            Text(formatter.string(from: NSNumber(value: traffic == .up ? up : down)) ?? "-")
        }
    }
}
