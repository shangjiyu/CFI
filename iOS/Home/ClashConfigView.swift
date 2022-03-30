import SwiftUI

struct ClashConfigView: View {
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
        
    private var predicate: NSPredicate {
        NSPredicate(format: "%K == %@", "uuid", (UUID(uuidString: self.uuidString) ?? UUID()).uuidString)
    }
    
    var body: some View {
        ManagedObjectFetchView(predicate: predicate) { (result: FetchedResults<ClashConfig>) in
            ModalPresentationLink {
                ClashConfigListView()
            } label: {
                label(result: result)
            }
        }
    }
    
    private func label(result: FetchedResults<ClashConfig>) -> some View {
        HStack {
            Label("配置", systemImage: "square.text.square")
            Spacer()
            Text(result.first.flatMap({ $0.name ?? "-" }) ?? "未选择")
                .fontWeight(.bold)
                .foregroundColor(Color.accentColor)
        }
    }
}
