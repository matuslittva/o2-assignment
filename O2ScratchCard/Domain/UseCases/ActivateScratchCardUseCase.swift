struct ActivateScratchCardUseCase: Sendable {
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

        let versionValue = try await activationRepository.activationVersion(for: code)
        guard let version = Double(versionValue) else {
            throw ActivationError.invalidVersion
        }
        guard version > 6.1 else {
            throw ActivationError.versionNotSupported
        }

        let activatedCard = ScratchCard(state: .activated(code: code))
        await cardRepository.save(activatedCard)
        return activatedCard
    }
}
