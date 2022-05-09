import SwiftUI

struct ImportButton: View {
    
    @State private var isConfirmationDialogPresented = false
    
    @Binding var importLocalFile: Bool
    @Binding var downloadRemoteFile: Bool
    
    var body: some View {
        Button {
            isConfirmationDialogPresented = true
        } label: {
            Image(systemName: "plus")
        }
        .confirmationDialog(Text("添加配置"), isPresented: $isConfirmationDialogPresented, titleVisibility: .visible) {
            Button(role: nil) {
                downloadRemoteFile.toggle()
            } label: {
                Text("下载配置文件")
            }
            Button(role: nil) {
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
