import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var manager: VPNManager
    
    @AppStorage(Clash.tunnelMode, store: .shared) private var tunnelMode: Clash.TunnelMode = .rule
    
    var body: some View {
        Form {
            ConfigSwitchView()
            Divider()
            TunnelModeView()
            Divider()
            if let controller = manager.controller {
                ControlView()
                    .environmentObject(controller)
            } else {
                InstallView()
            }
            Spacer()
        }
        .padding()
    }
}

struct ConfigSwitchView: View {
    
    @AppStorage(Clash.currentConfigUUID, store: .shared) private var uuidString: String = ""
        
    private var predicate: NSPredicate {
        NSPredicate(format: "%K == %@", "uuid", (UUID(uuidString: self.uuidString) ?? UUID()).uuidString)
    }
    
    var body: some View {
        ManagedObjectFetchView(predicate: predicate) { (result: FetchedResults<ClashConfig>) in
            ModalPresentationLink {
                ConfigListView()
            } label: {
                label(result: result)
            }
        }
    }
    
    private func label(result: FetchedResults<ClashConfig>) -> some View {
        Text(result.first.flatMap({ $0.name ?? "-" }) ?? "选择配置")
            .fontWeight(.bold)
            .foregroundColor(.accentColor)
            .padding(.vertical, 4)
    }
}
