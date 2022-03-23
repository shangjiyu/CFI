import Foundation

public enum ClashCommand: UInt8 {
    case setCurrentConfig
    case setTunnelMode
    case setLogLevel
    case patchSelectGroup
}

public struct ClashError: CustomNSError {
    
    public static let errorDomain: String = "com.Arror.Clash"
    
    public let errorCode: Int
    
    public let errorUserInfo: [String : Any]
    
    public init(code: Int, localizedDescription: String) {
        self.errorCode = code
        self.errorUserInfo = [NSLocalizedDescriptionKey: localizedDescription]
    }
    
    public static func custom(withLocalizedDescription description: String) -> ClashError {
        ClashError(code: 0, localizedDescription: description)
    }
}

public enum ClashLogLevel: String, Identifiable, CaseIterable {
        
    public var id: Self { self }
    
    case silent, info, debug, warning, error
}

public enum ClashTraffic: String {
    case up     = "ClashTrafficUP"
    case down   = "ClashTrafficDOWN"
}

public enum ClashTunnelMode: String, Hashable, Identifiable, CaseIterable {
    
    public var id: Self { self }
    
    case global, rule, direct
}
