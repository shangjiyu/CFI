import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIViewController
    
    @Binding var items: [Any]?
    let completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler?
        
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let items = items, !items.isEmpty, uiViewController.presentedViewController == nil else {
            return
        }
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.completionWithItemsHandler = { type, completed, items, error in
            self.items = nil
            guard let handler = completionWithItemsHandler else {
                return
            }
            handler(type, completed, items, error)
        }
        uiViewController.present(vc, animated: true, completion: nil)
    }
}

extension View {
    
    func activitySheet(items: Binding<[Any]?>, completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler? = nil) -> some View {
        self.background(ActivityView(items: items, completionWithItemsHandler: completionWithItemsHandler).ignoresSafeArea())
    }
}
