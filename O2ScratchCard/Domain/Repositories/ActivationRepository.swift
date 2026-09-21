protocol ActivationRepository: Sendable {
    func activationVersion(for code: String) async throws -> Version
}
