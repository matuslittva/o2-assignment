import Foundation

struct APIActivationRepository: ActivationRepository {
    private let endpoint: URL
    private let client: any HTTPClient
    private let converter: ActivationResponseConverter

    init(
        endpoint: URL,
        client: any HTTPClient,
        converter: ActivationResponseConverter
    ) {
        self.endpoint = endpoint
        self.client = client
        self.converter = converter
    }

    func activationVersion(for code: String) async throws -> Version {
        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            throw NetworkingError.invalidRequest
        }
        components.queryItems = [URLQueryItem(name: "code", value: code)]

        guard let url = components.url else {
            throw NetworkingError.invalidRequest
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let responseModel = try await client.send(request, as: ActivationResponse.self)
        return try converter.convert(responseModel)
    }
}
