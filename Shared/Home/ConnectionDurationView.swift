import SwiftUI

struct ConnectionDurationView: View {
        
    @EnvironmentObject private var controller: VPNController
    
    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1.0)) { _ in
#if os(macOS)
            Text(durationFormatString(current: Date()))
                .foregroundColor(.secondary)
#else
            HStack {
                Label("连接时间", systemImage: "clock")
                Spacer()
                Text(durationFormatString(current: Date()))
                    .foregroundColor(.secondary)
            }
#endif
        }
    }
    
    private func durationFormatString(current: Date) -> String {
        guard let date = controller.connectedDate else {
#if os(macOS)
            return "00:00:00"
#else
            return ""
#endif
        }
        let duration = Int64(abs(date.distance(to: current)))
        let hs = duration / 3600
        let ms = duration % 3600 / 60
        let ss = duration % 60
        return String(format: "%02d:%02d:%02d", hs, ms, ss)
    }
}
