import XCTest
@testable import O2ScratchCard

@MainActor
final class ActivateScratchCardUseCaseTests: XCTestCase {
    func test_givenScratchedCardAndSupportedVersion_whenActivated_thenStoresActivatedCard() async throws {
        let repository = ScratchCardRepositorySpy(
            card: ScratchCard(state: .scratched(code: "code"))
        )
        let sut = makeSUT(
            cardRepository: repository,
            activationRepository: ActivationRepositoryStub(outcome: .version("6.24"))
        )

        let card = try await sut()
        let storedCard = await repository.card()

        XCTAssertEqual(card.state, .activated(code: "code"))
        XCTAssertEqual(storedCard, card)
    }

    func test_givenVersionAtThreshold_whenActivated_thenThrowsUnsupportedVersionAndKeepsCard() async {
        let originalCard = ScratchCard(state: .scratched(code: "code"))
        let repository = ScratchCardRepositorySpy(card: originalCard)
        let sut = makeSUT(
            cardRepository: repository,
            activationRepository: ActivationRepositoryStub(outcome: .version("6.1"))
        )
        var receivedError: Error?

        do {
            _ = try await sut()
        } catch {
            receivedError = error
        }
        let storedCard = await repository.card()

        XCTAssertEqual(receivedError as? ActivationError, .versionNotSupported)
        XCTAssertEqual(storedCard, originalCard)
    }

    func test_givenInvalidVersion_whenActivated_thenThrowsInvalidVersionAndKeepsCard() async {
        let originalCard = ScratchCard(state: .scratched(code: "code"))
        let repository = ScratchCardRepositorySpy(card: originalCard)
        let sut = makeSUT(
            cardRepository: repository,
            activationRepository: ActivationRepositoryStub(outcome: .version("invalid"))
        )
        var receivedError: Error?

        do {
            _ = try await sut()
        } catch {
            receivedError = error
        }
        let storedCard = await repository.card()

        XCTAssertEqual(receivedError as? ActivationError, .invalidVersion)
        XCTAssertEqual(storedCard, originalCard)
    }

    func test_givenUnscratchedCard_whenActivated_thenThrowsCardIsNotScratched() async {
        let repository = ScratchCardRepositorySpy()
        let sut = makeSUT(
            cardRepository: repository,
            activationRepository: ActivationRepositoryStub(outcome: .failure)
        )
        var receivedError: Error?

        do {
            _ = try await sut()
        } catch {
            receivedError = error
        }

        XCTAssertEqual(receivedError as? ActivationError, .cardIsNotScratched)
    }
}

private extension ActivateScratchCardUseCaseTests {
    func makeSUT(
        cardRepository: any ScratchCardRepository,
        activationRepository: any ActivationRepository
    ) -> ActivateScratchCardUseCase {
        ActivateScratchCardUseCase(
            cardRepository: cardRepository,
            activationRepository: activationRepository
        )
    }
}
