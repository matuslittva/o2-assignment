import XCTest
@testable import O2ScratchCard

final class URLSessionHTTPClientTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.clearHandler()
        super.tearDown()
    }

    func test_givenNonSuccessfulResponse_whenRequestIsSent_thenThrowsHTTPError() async throws {
        let sut = try makeSUT(data: Data(), statusCode: 500)
        let request = try makeRequest()
        var receivedError: Error?

        do {
            let _: ActivationResponse = try await sut.send(request, as: ActivationResponse.self)
        } catch {
            receivedError = error
        }

        XCTAssertEqual(receivedError as? NetworkingError, .httpStatus(500))
    }

    func test_givenMalformedPayload_whenRequestIsSent_thenThrowsInvalidPayloadError() async throws {
        let sut = try makeSUT(data: Data(#"{"unexpected":true}"#.utf8))
        let request = try makeRequest()
        var receivedError: Error?

        do {
            let _: ActivationResponse = try await sut.send(request, as: ActivationResponse.self)
        } catch {
            receivedError = error
        }

        XCTAssertEqual(receivedError as? NetworkingError, .invalidPayload)
    }
}

private extension URLSessionHTTPClientTests {
    func makeSUT(
        data: Data,
        statusCode: Int = 200
    ) throws -> URLSessionHTTPClient {
        URLProtocolStub.setHandler { request in
            let response = try XCTUnwrap(
                HTTPURLResponse(
                    url: try XCTUnwrap(request.url),
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil
                )
            )
            return (response, data)
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSessionHTTPClient(
            session: URLSession(configuration: configuration),
            decoder: JSONDecoder()
        )
    }

    func makeRequest() throws -> URLRequest {
        URLRequest(url: try XCTUnwrap(URL(string: "https://api.o2.sk/version")))
    }
}
