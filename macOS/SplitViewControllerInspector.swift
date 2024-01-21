import SwiftUI

struct SplitViewControllerInspector: NSViewControllerRepresentable {
    
    private class ViewController: NSViewController {
        
        override func loadView() {
            self.view = NSView()
        }
        
        override func viewWillAppear() {
            super.viewWillAppear()
            
            guard let window = self.view.window else {
                return
            }
            var mask = window.styleMask
            mask.remove(.resizable)
            window.styleMask = mask
            
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

extension NSTableView {
    
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        self.backgroundColor = .clear
        self.enclosingScrollView?.drawsBackground = false
    }
}
