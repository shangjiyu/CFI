import Foundation

struct PatchData: Decodable {
    
    let current: String
    let histories: [DelayHistory]
    
    enum CodingKeys: String, CodingKey {
        case current    = "now"
        case histories  = "history"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.current = try container.decode(String.self, forKey: .current)
        } catch {
            self.current = ""
        }
        do {
            self.histories = try container.decode([DelayHistory].self, forKey: .histories)
        } catch {
            self.histories = []
        }
    }
}
