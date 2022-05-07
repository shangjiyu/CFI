import Foundation

enum Tab: String, Identifiable, Hashable, CaseIterable {
    
    var id: Self { self }
    
    case home, panel, setting
    
    var title: String {
        switch self {
        case .home:
            return "主页"
        case .panel:
            return "策略组"
        case .setting:
            return "设置"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .home:
            return "house"
        case .panel:
            return "square.stack.3d.up"
        case .setting:
            return "gearshape"
        }
    }
}
