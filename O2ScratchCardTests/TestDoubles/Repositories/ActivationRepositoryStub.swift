@testable import O2ScratchCard

struct ActivationRepositoryStub: ActivationRepository {
    enum Outcome: Sendable {
        case version(String)
        case failure
    }

    let outcome: Outcome

    func activationVersion(for code: String) async throws -> String {
        switch outcome {
        case let .version(version):
            version
        case .failure:
            throw TestError.expected
        }
    }
}
