import SwiftUI
import CommonKit

struct PanelView: View {
    
    @AppStorage(Constant.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    private var predicate: NSPredicate {
        NSPredicate(format: "%K == %@", "uuid", (UUID(uuidString: self.uuidString) ?? UUID()).uuidString)
    }
    
    var body: some View {
        NavigationView {
            ManagedObjectFetchView(sortDescriptors: [], predicate: predicate, animation: .default) { (result: FetchedResults<ClashConfig>) in
                buildBody(result: result)
            }
            .navigationBarTitle("面板")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func buildBody(result: FetchedResults<ClashConfig>) -> some View {
        if let reval = result.first {
            PanelInfoView()
                .environmentObject(PanelInfoModel(id: reval.uuid?.uuidString ?? "temp"))
        } else {
            Form {
                Text("未选择配置")
            }
        }
    }
}
