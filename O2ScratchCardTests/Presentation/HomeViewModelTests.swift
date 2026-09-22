import XCTest
@testable import O2ScratchCard

@MainActor
final class HomeViewModelTests: XCTestCase {
    func test_givenUnscratchedCard_whenCardIsUpdated_thenDisplaysUpdatedCard() {
        let card = ScratchCard(state: .unscratched)
        let repository = ScratchCardLocalRepository(card: card)
        let sut = makeSUT(repository: repository)
        let scratchedCard = ScratchCard(state: .scratched(code: "code"))

        sut.update(card: scratchedCard)

        XCTAssertEqual(sut.card, scratchedCard)
    }
}

private extension HomeViewModelTests {
    func makeSUT(
        repository: any ScratchCardRepository
    ) -> HomeViewModel {
        HomeViewModel(
            card: ScratchCard(state: .unscratched),
            getScratchCard: GetScratchCardUseCase(repository: repository)
        )
    }
}
