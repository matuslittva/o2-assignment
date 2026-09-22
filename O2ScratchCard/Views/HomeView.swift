import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    let onScratchCard: @MainActor () -> Void
    let onActivateCard: @MainActor () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                ScratchCardView(state: viewModel.card.state)
            }
            .padding()
        }
        .navigationTitle("O2 Scratch Card")
        .safeAreaInset(edge: .bottom) {
            BottomActionBar {
                PrimaryActionButton(
                    title: "Scratch card",
                    systemImage: "hand.tap",
                    isDisabled: false
                ) {
                    onScratchCard()
                }

                SecondaryActionButton(
                    title: "Activate card",
                    systemImage: "bolt.fill",
                    isDisabled: false
                ) {
                    onActivateCard()
                }
            }
        }
    }
}
