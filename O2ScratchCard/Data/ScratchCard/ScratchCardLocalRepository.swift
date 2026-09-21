actor ScratchCardLocalRepository: ScratchCardRepository {
    private var storedCard: ScratchCard

    init(card: ScratchCard) {
        storedCard = card
    }

    func card() -> ScratchCard {
        storedCard
    }

    func save(_ card: ScratchCard) {
        storedCard = card
    }
}
