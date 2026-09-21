enum NetworkingError: Error, Equatable, Sendable {
    case invalidRequest
    case invalidResponse
    case httpStatus(Int)
    case invalidPayload
    case transport
}
