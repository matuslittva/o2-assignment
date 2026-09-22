import SwiftUI

struct ActivationView: View {
    @StateObject var viewModel: ActivationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                ScratchCardView(state: viewModel.card.state)

                Group {
                    if viewModel.isActivating {
                        VStack(spacing: 12) {
                            ProgressView()
                                .controlSize(.large)
                            Text("Activating your card…")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        switch viewModel.card.state {
                        case .unscratched:
                            ContentUnavailableView(
                                "Code required",
                                systemImage: "lock",
                                description: Text("Scratch the card before activating it.")
                            )
                        case .scratched:
                            Text("The revealed code is ready to be activated.")
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        case .activated:
                            ContentUnavailableView(
                                "Activated",
                                systemImage: "checkmark.seal.fill",
                                description: Text("Your scratch card is active.")
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 130)
            }
            .padding()
        }
        .navigationTitle("Activate card")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            BottomActionBar {
                PrimaryActionButton(
                    title: "Activate card",
                    systemImage: "bolt.fill",
                    isDisabled: !viewModel.canActivate
                ) {
                    await viewModel.activate()
                }
            }
        }
        .appAlert($viewModel.alertState)
    }
}
