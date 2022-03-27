import SwiftUI

struct PanelView: View {
    
    @AppStorage(Constant.currentConfigUUID, store: .shared) private var uuidString: String = ""
    
    private var predicate: NSPredicate {
        NSPredicate(format: "%K == %@", "uuid", (UUID(uuidString: self.uuidString) ?? UUID()).uuidString)
    }
    
    var body: some View {
        ManagedObjectFetchView(sortDescriptors: [], predicate: predicate, animation: .default) { (result: FetchedResults<ClashConfig>) in
            buildBody(result: result)
        }
    }
    
    @ViewBuilder
    private func buildBody(result: FetchedResults<ClashConfig>) -> some View {
        if let reval = result.first {
            ProxyGroupView()
                .environmentObject(ProxyInfoModel(id: reval.uuid?.uuidString ?? "temp"))
        } else {
            Text("未选择 Clash 配置")
                .foregroundColor(.secondary)
        }
    }
}

