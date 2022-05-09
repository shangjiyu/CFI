import SwiftUI

struct ConfigSwitchView: View {
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    @FetchRequest(
        sortDescriptors: [],
        animation: nil
    ) private var configs: FetchedResults<ClashConfig>
    
    private var title: String {
        configs.first(where: { $0.uuid?.uuidString == uuidString }).flatMap({ $0.name ?? "-" }) ?? "未选择"
    }
    
    var body: some View {
#if os(macOS)
        HStack {
            TextField("配置: ", text: .constant(title), prompt: nil)
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
#else
        ModalPresentationLink {
            ConfigListView()
        } label: {
            HStack {
                Label("配置", systemImage: "square.text.square")
                Spacer()
                Text(title)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .foregroundColor(Color.accentColor)
            }
        }
#endif
    }
}
