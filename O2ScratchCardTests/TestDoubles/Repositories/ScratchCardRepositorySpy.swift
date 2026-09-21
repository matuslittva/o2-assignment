@testable import O2ScratchCard

actor ScratchCardRepositorySpy: ScratchCardRepository {
    private var storedCard: ScratchCard
    private var cards: [ScratchCard] = []

    init(card: ScratchCard = ScratchCard()) {
        storedCard = card
    }

    func card() -> ScratchCard {
        storedCard
    }

    func save(_ card: ScratchCard) {
        storedCard = card
        cards.append(card)
    }

    func savedCards() -> [ScratchCard] {
        cards
    }
}
