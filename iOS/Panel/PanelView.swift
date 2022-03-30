import SwiftUI

struct PanelView: View {
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
        
    @StateObject var viewModel = ProxyGroupListViewModel()
    
    var body: some View {
        NavigationView {
            _body
                .navigationBarTitle("策略组")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var _body: some View {
        if uuidString.isEmpty {
            Text("未选择配置")
                .foregroundColor(.secondary)
        } else {
            ProxyGroupListView()
                .onChange(of: uuidString) { newValue in
                    viewModel.update(uuidString: newValue)
                }
                .onAppear {
                    viewModel.update(uuidString: uuidString)
                }
                .environmentObject(viewModel)
        }
    }
}
