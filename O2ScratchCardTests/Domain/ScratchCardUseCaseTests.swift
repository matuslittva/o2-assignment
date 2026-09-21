import XCTest
@testable import O2ScratchCard

@MainActor
final class ScratchCardUseCaseTests: XCTestCase {
    func test_givenUnscratchedCard_whenScratched_thenGeneratesAndStoresCode() async throws {
        let repository = ScratchCardRepositorySpy()
        let sut = makeSUT(
            repository: repository,
            generateCode: { "generated-code" }
        )

        let card = try await sut()
        let storedCard = await repository.card()
        let savedCards = await repository.savedCards()

        XCTAssertEqual(card.state, .scratched(code: "generated-code"))
        XCTAssertEqual(storedCard, card)
        XCTAssertEqual(savedCards, [card])
    }

    func test_givenCancelledDelay_whenScratched_thenKeepsCardUnscratched() async {
        let repository = ScratchCardRepositorySpy()
        let sut = makeSUT(
            repository: repository,
            delay: { throw CancellationError() }
        )
        var receivedError: Error?

        do {
            _ = try await sut()
        } catch {
            receivedError = error
        }
        let storedCard = await repository.card()
        let savedCards = await repository.savedCards()

        XCTAssertTrue(receivedError is CancellationError)
        XCTAssertEqual(storedCard.state, .unscratched)
        XCTAssertEqual(savedCards, [])
    }

    func test_givenAlreadyScratchedCard_whenScratched_thenThrowsAlreadyScratched() async {
        let repository = ScratchCardRepositorySpy(
            card: ScratchCard(state: .scratched(code: "existing"))
        )
        let sut = makeSUT(
            repository: repository,
            generateCode: { "new" }
        )
        var receivedError: Error?

        do {
            _ = try await sut()
        } catch {
            receivedError = error
        }

        XCTAssertEqual(receivedError as? ScratchCardError, .alreadyScratched)
    }
}

private extension ScratchCardUseCaseTests {
    func makeSUT(
        repository: any ScratchCardRepository,
        delay: @escaping @Sendable () async throws -> Void = {},
        generateCode: @escaping @Sendable () -> String = { "code" }
    ) -> ScratchCardUseCase {
        ScratchCardUseCase(
            repository: repository,
            delay: delay,
            generateCode: generateCode
        )
    }
}
