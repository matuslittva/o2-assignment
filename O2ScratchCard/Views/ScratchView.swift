import SwiftUI

struct ScratchView: View {
    @StateObject var viewModel: ScratchViewModel
    @State private var shouldScratch = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                ScratchCardView(state: viewModel.card.state)

                Group {
                    if viewModel.isScratching {
                        VStack(spacing: 12) {
                            ProgressView()
                                .controlSize(.large)
                            Text("Revealing your code…")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        switch viewModel.card.state {
                        case .unscratched:
                            Text("Tap the button to reveal the activation code. This takes about two seconds.")
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        case .scratched, .activated:
                            Label("The code has been revealed", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 72)
            }
            .padding()
        }
        .navigationTitle("Scratch card")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            BottomActionBar {
                PrimaryActionButton(
                    title: "Reveal code",
                    systemImage: "sparkles",
                    isDisabled: !viewModel.canScratch
                ) {
                    shouldScratch = true
                }
            }
        }
        .appAlert($viewModel.alertState)
        .sensoryFeedback(.success, trigger: viewModel.card.state) { oldState, newState in
            oldState != newState
        }
        .task(id: shouldScratch) {
            guard shouldScratch else { return }
            await viewModel.scratch()
            shouldScratch = false
        }
    }
}
