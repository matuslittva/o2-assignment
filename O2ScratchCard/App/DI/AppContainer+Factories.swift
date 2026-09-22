import Foundation

extension AppContainer {
    func makeGetScratchCardUseCase() -> GetScratchCardUseCase {
        GetScratchCardUseCase(repository: cardRepository)
    }

    func makeScratchCardUseCase() -> ScratchCardUseCase {
        ScratchCardUseCase(
            repository: cardRepository,
            delay: {
                try await Task.sleep(for: .seconds(2))
            },
            generateCode: {
                UUID().uuidString
            }
        )
    }

    func makeActivateScratchCardUseCase() -> ActivateScratchCardUseCase {
        ActivateScratchCardUseCase(
            cardRepository: cardRepository,
            activationRepository: activationRepository
        )
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            card: ScratchCard(state: .unscratched),
            getScratchCard: makeGetScratchCardUseCase()
        )
    }

    func makeScratchViewModel(
        card: ScratchCard,
        onCardChanged: @escaping @MainActor (ScratchCard) -> Void
    ) -> ScratchViewModel {
        ScratchViewModel(
            card: card,
            scratchCard: self.makeScratchCardUseCase(),
            onCardChanged: onCardChanged
        )
    }

    func makeScratchView(
        card: ScratchCard,
        onCardChanged: @escaping @MainActor (ScratchCard) -> Void
    ) -> ScratchView {
        ScratchView(
            viewModel: self.makeScratchViewModel(
                card: card,
                onCardChanged: onCardChanged
            )
        )
    }

    func makeActivationViewModel(
        card: ScratchCard,
        onCardChanged: @escaping @MainActor (ScratchCard) -> Void
    ) -> ActivationViewModel {
        ActivationViewModel(
            card: card,
            activateScratchCard: self.makeActivateScratchCardUseCase(),
            onCardChanged: onCardChanged
        )
    }

    func makeActivationView(
        card: ScratchCard,
        onCardChanged: @escaping @MainActor (ScratchCard) -> Void
    ) -> ActivationView {
        ActivationView(
            viewModel: self.makeActivationViewModel(
                card: card,
                onCardChanged: onCardChanged
            )
        )
    }
}
