import XCTest
@testable import O2ScratchCard

final class APIActivationRepositoryTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.clearHandler()
        super.tearDown()
    }

    func test_givenSuccessfulResponse_whenVersionIsRequested_thenBuildsGETRequestAndReturnsVersion() async throws {
        let recorder = RequestRecorder()
        let sut = try makeSUT(data: Data(#"{"ios":"6.24"}"#.utf8)) { request in
            recorder.record(request)
        }

        let version = try await sut.activationVersion(for: "a code")
        let request = recorder.recordedRequest()
        let components = try XCTUnwrap(
            URLComponents(url: try XCTUnwrap(request?.url), resolvingAgainstBaseURL: false)
        )

        XCTAssertEqual(version, Version(major: 6, minor: 24, patch: 0))
        XCTAssertEqual(request?.httpMethod, "GET")
        XCTAssertEqual(components.queryItems, [URLQueryItem(name: "code", value: "a code")])
    }
}

private extension APIActivationRepositoryTests {
    func makeSUT(
        data: Data,
        statusCode: Int = 200,
        inspectRequest: @escaping @Sendable (URLRequest) -> Void = { _ in }
    ) throws -> APIActivationRepository {
        let endpoint = try XCTUnwrap(URL(string: "https://api.o2.sk/version"))
        URLProtocolStub.setHandler { request in
            inspectRequest(request)
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
        return APIActivationRepository(
            endpoint: endpoint,
            client: URLSessionHTTPClient(
                session: URLSession(configuration: configuration),
                decoder: JSONDecoder()
            ),
            converter: ActivationResponseConverter()
        )
    }
}
