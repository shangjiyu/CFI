import Foundation

enum Page: String, Identifiable, CaseIterable, Hashable {
    
    var id: Self { self }
    
    case home, config, panel, log, setting
    
    var title: String {
        switch self {
        case .home:
            return "主页"
        case .config:
            return "配置"
        case .panel:
            return "面板"
        case .log:
            return "日志"
        case .setting:
            return "设置"
        }
    }
    
    var image: String {
        switch self {
        case .home:
            return "house"
        case .config:
            return "square.text.square"
        case .panel:
            return "square.stack.3d.up"
        case .log:
            return "doc.text"
        case .setting:
            return "gearshape"
        }
    }
}
