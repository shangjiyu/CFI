import SwiftUI

struct ClashTrafficUpView: View {
    
    @AppStorage(Clash.Traffic.up.rawValue, store: .shared) private var up: Double = 0
    
    var body: some View {
        ClashTrafficView(traffic: .up, binding: $up)
    }
}

struct ClashTrafficDownView: View {
    
    @AppStorage(Clash.Traffic.down.rawValue, store: .shared) private var down: Double = 0
    
    var body: some View {
        ClashTrafficView(traffic: .down, binding: $down)
    }
}

private struct ClashTrafficView: View {
    
    @Environment(\.trafficFormatter) private var formatter: NumberFormatter
    
    let traffic: Clash.Traffic
    let binding: Binding<Double>
    
    init(traffic: Clash.Traffic, binding: Binding<Double>) {
        self.traffic = traffic
        self.binding = binding
    }
    
    var body: some View {
        HStack {
            Label(self.traffic.title, systemImage: self.traffic.imageName)
            Spacer()
            Text(formatter.string(from: NSNumber(value: self.binding.wrappedValue)) ?? "-")
                .fontWeight(.bold)
        }
    }
}
