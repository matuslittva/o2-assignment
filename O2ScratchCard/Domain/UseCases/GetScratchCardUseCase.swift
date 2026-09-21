struct GetScratchCardUseCase: Sendable {
    private let repository: any ScratchCardRepository

    init(repository: any ScratchCardRepository) {
        self.repository = repository
    }

    func callAsFunction() async -> ScratchCard {
        await repository.card()
    }
}
