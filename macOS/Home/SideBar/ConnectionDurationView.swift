import SwiftUI

struct ConnectionDurationView: View {
    
    @Environment(\.trafficFormatter) private var formatter: NumberFormatter
    
    @EnvironmentObject private var controller: VPNController
    
    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1.0)) { context in
            Text(durationFormatString(current: context.date))
                .foregroundColor(.secondary)
        }
    }
    
    private func durationFormatString(current: Date) -> String {
        guard let date = controller.connectedDate else {
            return "00:00:00"
        }
        let duration = Int64(abs(date.distance(to: current)))
        let hs = duration / 3600
        let ms = duration % 3600 / 60
        let ss = duration % 60
        return String(format: "%02d:%02d:%02d", hs, ms, ss)
    }
}
