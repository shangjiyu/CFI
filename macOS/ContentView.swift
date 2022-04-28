import SwiftUI
import Introspect

struct ContentView: View {
    
    @AppStorage("TAB_MACOS") private var currentTab: Tab = .home
    
    var body: some View {
        NavigationView {
            SideBarView(binding: $currentTab)
                .background(SplitViewControllerInspector())
            switch currentTab {
            case .home:
                HomeView()
            case .panel:
                PanelView()
            case .setting:
                SettingView()
            }
        }
        .frame(height: 540)
        .introspect(selector: { $0 }) { view in
            guard let window = view.window else {
                return
            }
            var mask = window.styleMask
            mask.remove(.resizable)
            window.styleMask = mask
        }
    }
}

struct SplitViewControllerInspector: NSViewControllerRepresentable {
    
    private class ViewController: NSViewController {
        
        override func loadView() {
            self.view = NSView()
        }
        
        override func viewWillAppear() {
            super.viewWillAppear()
            guard let vc = self.findSplitViewController() else {
                return
            }
            vc.splitViewItems.forEach { $0.canCollapse = false }
            if let first = vc.splitView.arrangedSubviews.first {
                first.widthAnchor.constraint(equalToConstant: 240).isActive = true
            }
            if let last = vc.splitView.arrangedSubviews.last {
                last.widthAnchor.constraint(equalToConstant: 600).isActive = true
            }
        }
        
        private func findSplitViewController() -> NSSplitViewController? {
            var next = self.nextResponder
            while next != nil {
                if let vc = next as? NSSplitViewController {
                    return vc
                }
                next = next?.nextResponder
            }
            return nil
        }
    }
    
    typealias NSViewControllerType = NSViewController
        
    func makeNSViewController(context: Context) -> NSViewController {
        ViewController()
    }
    
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}
}
