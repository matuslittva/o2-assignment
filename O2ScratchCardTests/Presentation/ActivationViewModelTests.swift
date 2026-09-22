import XCTest
@testable import O2ScratchCard

@MainActor
final class ActivationViewModelTests: XCTestCase {
    func test_givenSupportedVersion_whenActivated_thenUpdatesCardWithoutAlert() async {
        let card = ScratchCard(state: .scratched(code: "code"))
        let repository = ScratchCardLocalRepository(card: card)
        let sut = makeSUT(
            card: card,
            cardRepository: repository,
            activationRepository: ActivationRepositoryStub(
                outcome: .version(Version(major: 6, minor: 24, patch: 0))
            )
        )

        await sut.activate()

        XCTAssertEqual(sut.card.state, .activated(code: "code"))
        XCTAssertFalse(sut.isActivating)
        XCTAssertNil(sut.alertState)
    }

    func test_givenUnsupportedVersion_whenActivated_thenPresentsVersionNotSupportedAlert() async {
        let card = ScratchCard(state: .scratched(code: "code"))
        let repository = ScratchCardLocalRepository(card: card)
        let sut = makeSUT(
            card: card,
            cardRepository: repository,
            activationRepository: ActivationRepositoryStub(
                outcome: .version(Version(major: 6, minor: 1, patch: 0))
            )
        )

        await sut.activate()

        XCTAssertEqual(sut.alertState?.title, "Activation unavailable")
        XCTAssertEqual(
            sut.alertState?.message,
            "The service version does not support activation."
        )
        XCTAssertFalse(sut.isActivating)
    }

    func test_givenRepositoryFailure_whenActivated_thenPresentsActivationFailedAlert() async {
        let card = ScratchCard(state: .scratched(code: "code"))
        let repository = ScratchCardLocalRepository(card: card)
        let sut = makeSUT(
            card: card,
            cardRepository: repository,
            activationRepository: ActivationRepositoryStub(outcome: .failure)
        )

        await sut.activate()

        XCTAssertEqual(sut.alertState?.title, "Activation failed")
        XCTAssertEqual(
            sut.alertState?.message,
            "The card could not be activated. Please try again."
        )
        XCTAssertFalse(sut.isActivating)
    }
}

private extension ActivationViewModelTests {
    func makeSUT(
        card: ScratchCard,
        cardRepository: any ScratchCardRepository,
        activationRepository: any ActivationRepository
    ) -> ActivationViewModel {
        ActivationViewModel(
            card: card,
            activateScratchCard: ActivateScratchCardUseCase(
                cardRepository: cardRepository,
                activationRepository: activationRepository
            ),
            onCardChanged: { _ in }
        )
    }
}
