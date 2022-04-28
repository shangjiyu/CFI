import AppKit

enum Theme: Int, Identifiable, CaseIterable, CustomStringConvertible {
    
    var id: Theme { self }
    
    case light, dark, system
    
    var description: String {
        switch self {
        case .light:
            return "浅色"
        case .dark:
            return "深色"
        case .system:
            return "跟随系统"
        }
    }
    
    func applyAppearance() {
        switch self {
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        case .system:
            NSApp.appearance = nil
        }
    }
}
