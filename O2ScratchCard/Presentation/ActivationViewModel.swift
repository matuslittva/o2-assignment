import Combine

@MainActor
final class ActivationViewModel: ObservableObject {
    @Published private(set) var card: ScratchCard
    @Published private(set) var isActivating = false
    @Published var alertState: AlertState?

    private let activateScratchCard: ActivateScratchCardUseCase
    private let onCardChanged: @MainActor (ScratchCard) -> Void

    init(
        card: ScratchCard,
        activateScratchCard: ActivateScratchCardUseCase,
        onCardChanged: @escaping @MainActor (ScratchCard) -> Void
    ) {
        self.card = card
        self.activateScratchCard = activateScratchCard
        self.onCardChanged = onCardChanged
    }

    var canActivate: Bool {
        guard case .scratched = card.state else { return false }
        return !isActivating
    }

    func activate() async {
        guard canActivate else { return }

        isActivating = true
        alertState = nil

        do {
            let card = try await activateScratchCard()
            self.card = card
            onCardChanged(card)
        } catch ActivationError.versionNotSupported {
            alertState = AlertState(
                title: "Activation unavailable",
                message: "The service version does not support activation."
            )
        } catch {
            alertState = AlertState(
                title: "Activation failed",
                message: "The card could not be activated. Please try again."
            )
        }

        isActivating = false
    }
}
