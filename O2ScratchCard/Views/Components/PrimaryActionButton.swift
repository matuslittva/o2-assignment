import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    let systemImage: String
    let isDisabled: Bool
    let action: @MainActor () async -> Void

    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isDisabled)
    }
}
