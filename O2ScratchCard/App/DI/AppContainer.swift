import Foundation

@MainActor
final class AppContainer {
    let cardRepository: any ScratchCardRepository
    let activationRepository: any ActivationRepository

    init(
        cardRepository: any ScratchCardRepository,
        activationRepository: any ActivationRepository
    ) {
        self.cardRepository = cardRepository
        self.activationRepository = activationRepository
    }

    static func live() -> AppContainer {
        let cardRepository = makeCardRepository()
        let httpClient = makeHTTPClient()
        let activationRepository = makeActivationRepository(client: httpClient)

        return AppContainer(
            cardRepository: cardRepository,
            activationRepository: activationRepository
        )
    }
}

private extension AppContainer {
    static func makeCardRepository() -> ScratchCardLocalRepository {
        ScratchCardLocalRepository(card: ScratchCard(state: .unscratched))
    }

    static func makeHTTPClient() -> URLSessionHTTPClient {
        URLSessionHTTPClient(
            session: .shared,
            decoder: JSONDecoder()
        )
    }

    static func makeActivationRepository(
        client: any HTTPClient
    ) -> APIActivationRepository {
        APIActivationRepository(
            endpoint: URL(string: "https://api.o2.sk/version")!,
            client: client,
            converter: ActivationResponseConverter()
        )
    }
}
