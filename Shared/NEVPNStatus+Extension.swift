import NetworkExtension

extension NEVPNStatus {
    
    public var displayString: String {
        switch self {
        case .invalid:
            return "不可用"
        case .connecting:
            return "正在连接..."
        case .connected:
            return "已连接"
        case .reasserting:
            return "正在重新连接..."
        case .disconnecting:
            return "正在断开连接..."
        case .disconnected:
            return "未连接"
        @unknown default:
            return "未知"
        }
    }
}
