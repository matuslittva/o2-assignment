struct ActivateScratchCardUseCase: Sendable {
    private static let requiredVersion = Version(major: 6, minor: 1, patch: 0)

    private let cardRepository: any ScratchCardRepository
    private let activationRepository: any ActivationRepository

    init(
        cardRepository: any ScratchCardRepository,
        activationRepository: any ActivationRepository
    ) {
        self.cardRepository = cardRepository
        self.activationRepository = activationRepository
    }

    @discardableResult
    func callAsFunction() async throws -> ScratchCard {
        let card = await cardRepository.card()
        guard case let .scratched(code) = card.state else {
            throw ActivationError.cardIsNotScratched
        }

        let version = try await activationRepository.activationVersion(for: code)
        guard version > Self.requiredVersion else {
            throw ActivationError.versionNotSupported
        }

        let activatedCard = ScratchCard(state: .activated(code: code))
        await cardRepository.save(activatedCard)
        return activatedCard
    }
}
