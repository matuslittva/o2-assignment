import SwiftUI

extension View {
    func appAlert(_ state: Binding<AlertState?>) -> some View {
        alert(item: state) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .cancel(Text("OK"))
            )
        }
    }
}
