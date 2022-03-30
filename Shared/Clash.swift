import Foundation

public enum ClashCommand: UInt8 {
    case setCurrentConfig
    case setTunnelMode
    case setLogLevel
    case setSelectGroup
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

public enum Clash {}

extension Clash {
    
    public enum Command: UInt8 {
        case setConfig
        case setTunnelMode
        case setLogLevel
        case setSelectGroup
    }
    
    public enum LogLevel: String, Identifiable, CaseIterable {
            
        public var id: Self { self }
        
        case silent, info, debug, warning, error
    }
    
    public enum Traffic: String {
        case up     = "ClashTrafficUP"
        case down   = "ClashTrafficDOWN"
    }
    
    public enum TunnelMode: String, Hashable, Identifiable, CaseIterable {
        
        public var id: Self { self }
        
        case global, rule, direct
    }
}
