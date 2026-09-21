import Foundation

struct ScratchCardUseCase: Sendable {
    private let repository: any ScratchCardRepository
    private let delay: @Sendable () async throws -> Void
    private let generateCode: @Sendable () -> String

    init(
        repository: any ScratchCardRepository,
        delay: @escaping @Sendable () async throws -> Void = {
            try await Task.sleep(for: .seconds(2))
        },
        generateCode: @escaping @Sendable () -> String = {
            UUID().uuidString
        }
    ) {
        self.repository = repository
        self.delay = delay
        self.generateCode = generateCode
    }

    @discardableResult
    func callAsFunction() async throws -> ScratchCard {
        let card = await repository.card()
        guard case .unscratched = card.state else {
            throw ScratchCardError.alreadyScratched
        }

        try await delay()
        try Task.checkCancellation()

        let code = generateCode()
        let scratchedCard = ScratchCard(state: .scratched(code: code))
        await repository.save(scratchedCard)
        return scratchedCard
    }
}
