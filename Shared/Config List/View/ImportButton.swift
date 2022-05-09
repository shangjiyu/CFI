import SwiftUI

struct ImportButton: View {
    
    @State private var isConfirmationDialogPresented = false
    
    @Binding var importLocalFile: Bool
    @Binding var downloadRemoteFile: Bool
    
    var body: some View {
        Button {
            isConfirmationDialogPresented = true
        } label: {
#if os(macOS)
            Text("导入")
                .fontWeight(.medium)
#else
            Image(systemName: "plus")
#endif
        }
        .confirmationDialog(Text("添加配置"), isPresented: $isConfirmationDialogPresented, titleVisibility: .visible) {
            Button {
                downloadRemoteFile.toggle()
            } label: {
                Text("下载配置文件")
            }
            Button {
                importLocalFile.toggle()
            } label: {
                Text("导入本地配置文件")
            }
            Button("取消", role: .cancel, action: {})
        } message: {
            Text("从网络下载或者本地导入配置文件")
        }
    }
}
