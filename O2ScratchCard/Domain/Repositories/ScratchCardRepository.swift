protocol ScratchCardRepository: Sendable {
    func card() async -> ScratchCard

    func save(_ card: ScratchCard) async
}
