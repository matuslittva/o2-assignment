import XCTest
@testable import O2ScratchCard

@MainActor
final class ScratchViewModelTests: XCTestCase {
    func test_givenUnscratchedCard_whenScratchingFinishes_thenUpdatesCardWithoutAlert() async {
        let repository = ScratchCardLocalRepository(
            card: ScratchCard(state: .unscratched)
        )
        let sut = makeSUT(
            repository: repository,
            generateCode: { "code" }
        )

        await sut.scratch()

        XCTAssertEqual(sut.card.state, .scratched(code: "code"))
        XCTAssertFalse(sut.isScratching)
        XCTAssertNil(sut.alertState)
    }

    func test_givenCancelledScratch_whenScratched_thenKeepsCardUnscratchedWithoutAlert() async {
        let repository = ScratchCardLocalRepository(
            card: ScratchCard(state: .unscratched)
        )
        let sut = makeSUT(
            repository: repository,
            delay: { throw CancellationError() }
        )

        await sut.scratch()
        let card = await repository.card()

        XCTAssertEqual(card.state, .unscratched)
        XCTAssertFalse(sut.isScratching)
        XCTAssertNil(sut.alertState)
    }

    func test_givenScratchedCard_whenCanScratchIsRequested_thenReturnsFalse() {
        let card = ScratchCard(state: .scratched(code: "code"))
        let repository = ScratchCardLocalRepository(card: card)
        let sut = makeSUT(
            card: card,
            repository: repository
        )

        let canScratch = sut.canScratch

        XCTAssertFalse(canScratch)
    }
}

private extension ScratchViewModelTests {
    func makeSUT(
        card: ScratchCard = ScratchCard(),
        repository: any ScratchCardRepository,
        delay: @escaping @Sendable () async throws -> Void = {},
        generateCode: @escaping @Sendable () -> String = { "code" }
    ) -> ScratchViewModel {
        ScratchViewModel(
            card: card,
            scratchCard: ScratchCardUseCase(
                repository: repository,
                delay: delay,
                generateCode: generateCode
            ),
            onCardChanged: { _ in }
        )
    }
}
