import Foundation
import SwiftUI

class ProxyViewModel: ObservableObject {
    
    let name: String
    let type: String
    @Published var histories: [DelayHistory]
    
    init(name: String, type: String, histories: [DelayHistory]) {
        self.name = name
        self.type = type
        self.histories = histories
    }
    
    var delay: String {
        guard let last = histories.first else {
            return ""
        }
        if last.delay == 0 {
            return "超时"
        } else {
            return "\(last.delay)ms"
        }
    }
    
    var delayTextColor: Color {
        guard let last = histories.first else {
            return .clear
        }
        if last.delay == 0 {
            return .secondary
        } else if last.delay <= 300 {
            return .green
        } else if last.delay <= 600 {
            return .yellow
        } else {
            return .red
        }
    }
}
