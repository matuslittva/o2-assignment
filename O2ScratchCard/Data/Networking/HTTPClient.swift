import Foundation

protocol HTTPClient: Sendable {
    func send<Response: Decodable & Sendable>(
        _ request: URLRequest,
        as responseType: Response.Type
    ) async throws -> Response
}

struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession,
        decoder: JSONDecoder
    ) {
        self.session = session
        self.decoder = decoder
    }

    func send<Response: Decodable & Sendable>(
        _ request: URLRequest,
        as responseType: Response.Type
    ) async throws -> Response {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw NetworkingError.transport
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkingError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkingError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(responseType, from: data)
        } catch {
            throw NetworkingError.invalidPayload
        }
    }
}
