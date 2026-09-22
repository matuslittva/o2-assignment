import Combine

@MainActor
final class ScratchViewModel: ObservableObject {
    @Published private(set) var card: ScratchCard
    @Published private(set) var isScratching = false
    @Published var alertState: AlertState?

    private let scratchCard: ScratchCardUseCase
    private let onCardChanged: @MainActor (ScratchCard) -> Void

    init(
        card: ScratchCard,
        scratchCard: ScratchCardUseCase,
        onCardChanged: @escaping @MainActor (ScratchCard) -> Void
    ) {
        self.card = card
        self.scratchCard = scratchCard
        self.onCardChanged = onCardChanged
    }

    var canScratch: Bool {
        guard case .unscratched = card.state else { return false }
        return !isScratching
    }

    func scratch() async {
        guard canScratch else { return }

        isScratching = true
        alertState = nil

        do {
            let card = try await scratchCard()
            self.card = card
            onCardChanged(card)
        } catch {
            if !(error is CancellationError) {
                alertState = AlertState(
                    title: "Unable to scratch card",
                    message: "The card could not be scratched. Please try again."
                )
            }
        }

        isScratching = false
    }
}
