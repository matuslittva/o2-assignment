enum ActivationError: Error, Equatable, Sendable {
    case cardIsNotScratched
    case invalidVersion
    case versionNotSupported
}
