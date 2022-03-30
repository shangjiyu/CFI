import Foundation

extension UserDefaults {
    public static let shared: UserDefaults = UserDefaults(suiteName: Clash.appGroup)!
}
