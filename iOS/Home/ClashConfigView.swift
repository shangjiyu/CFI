import SwiftUI

struct ClashConfigView: View {
    
    @AppStorage(Constant.currentConfigUUID, store: .shared) private var uuidString: String = ""
        
    private var predicate: NSPredicate {
        NSPredicate(format: "%K == %@", "uuid", (UUID(uuidString: self.uuidString) ?? UUID()).uuidString)
    }
    
    var body: some View {
        ManagedObjectFetchView(predicate: predicate) { (result: FetchedResults<ClashConfig>) in
            #if os(macOS)
            label(result: result)
                .contentShape(Rectangle())
            #else
            ModalPresentationLink {
                ClashConfigListView()
            } label: {
                label(result: result)
            }
            #endif
        }
    }
    
    private func label(result: FetchedResults<ClashConfig>) -> some View {
        HStack {
            Image(systemName: "square.text.square")
                .font(.title2)
                .foregroundColor(Color.accentColor)
            Text("配置")
            Spacer()
            Text(result.first.flatMap({ $0.name ?? "-" }) ?? "未选择")
                .fontWeight(.bold)
                .foregroundColor(Color.accentColor)
        }
    }
}
