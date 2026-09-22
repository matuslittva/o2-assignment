import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var card: ScratchCard

    private let getScratchCard: GetScratchCardUseCase

    init(
        card: ScratchCard,
        getScratchCard: GetScratchCardUseCase
    ) {
        self.card = card
        self.getScratchCard = getScratchCard
    }

    func load() async {
        card = await getScratchCard()
    }

    func update(card: ScratchCard) {
        self.card = card
    }
}
