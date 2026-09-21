import XCTest
@testable import O2ScratchCard

@MainActor
final class ScratchCardLocalRepositoryTests: XCTestCase {
    func test_givenCard_whenCardIsSaved_thenRepositoryStoresIt() async {
        let sut = makeSUT()
        let scratchedCard = ScratchCard(state: .scratched(code: "code"))

        await sut.save(scratchedCard)
        let storedCard = await sut.card()

        XCTAssertEqual(storedCard, scratchedCard)
    }
}

private extension ScratchCardLocalRepositoryTests {
    func makeSUT(
        card: ScratchCard = ScratchCard()
    ) -> ScratchCardLocalRepository {
        ScratchCardLocalRepository(card: card)
    }
}
