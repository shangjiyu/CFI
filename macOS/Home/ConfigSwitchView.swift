import SwiftUI

struct ConfigSwitchView: View {
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    @FetchRequest(
        sortDescriptors: [],
        animation: nil
    ) private var configs: FetchedResults<ClashConfig>
    
    var body: some View {
        HStack {
            TextField("配置: ", text: .constant(configs.first(where: { $0.uuid?.uuidString == uuidString }).flatMap({ $0.name ?? "-" }) ?? "未选择"), prompt: nil)
                .textFieldStyle(.plain)
                .allowsHitTesting(false)
                .focusable(false)
            ModalPresentationLink {
                ConfigListView()
            } label: {
                Text("切换")
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
            }
        }
    }
}
