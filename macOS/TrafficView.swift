import SwiftUI

private extension ClashTraffic {
    
    var title: String {
        switch self {
        case .up:
            return "上传"
        case .down:
            return "下载"
        }
    }
    
    var imageName: String {
        switch self {
        case .up:
            return "arrow.up"
        case .down:
            return "arrow.down"
        }
    }
}

struct TrafficView: View {
    
    @Environment(\.trafficFormatter) private var formatter: NumberFormatter
    
    @AppStorage(ClashTraffic.up.rawValue, store: .shared) private var up: Double = 0
    @AppStorage(ClashTraffic.down.rawValue, store: .shared) private var down: Double = 0
        
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
    
    private func buildElementView(traffic: ClashTraffic) -> some View {
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
