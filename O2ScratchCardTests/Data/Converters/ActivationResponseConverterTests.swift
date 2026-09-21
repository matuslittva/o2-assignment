import XCTest
@testable import O2ScratchCard

final class ActivationResponseConverterTests: XCTestCase {
    func test_givenThreeComponentVersion_whenConverted_thenReturnsVersion() throws {
        let sut = makeSUT()
        let response = ActivationResponse(ios: "6.52.2")

        let version = try sut.convert(response)

        XCTAssertEqual(version, Version(major: 6, minor: 52, patch: 2))
    }

    func test_givenTwoComponentVersion_whenConverted_thenUsesZeroPatch() throws {
        let sut = makeSUT()
        let response = ActivationResponse(ios: "6.24")

        let version = try sut.convert(response)

        XCTAssertEqual(version, Version(major: 6, minor: 24, patch: 0))
    }

    func test_givenInvalidVersion_whenConverted_thenThrowsInvalidPayload() {
        let sut = makeSUT()
        let response = ActivationResponse(ios: "invalid")
        var receivedError: Error?

        do {
            _ = try sut.convert(response)
        } catch {
            receivedError = error
        }

        XCTAssertEqual(receivedError as? NetworkingError, .invalidPayload)
    }
}

private extension ActivationResponseConverterTests {
    func makeSUT() -> ActivationResponseConverter {
        ActivationResponseConverter()
    }
}
