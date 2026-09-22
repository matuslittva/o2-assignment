@MainActor
final class AppContainer {
    let cardRepository: any ScratchCardRepository

    init(cardRepository: any ScratchCardRepository) {
        self.cardRepository = cardRepository
    }

    static func live() -> AppContainer {
        let cardRepository = makeCardRepository()
        return AppContainer(cardRepository: cardRepository)
    }
}

private extension AppContainer {
    static func makeCardRepository() -> ScratchCardLocalRepository {
        ScratchCardLocalRepository(card: ScratchCard(state: .unscratched))
    }
}
