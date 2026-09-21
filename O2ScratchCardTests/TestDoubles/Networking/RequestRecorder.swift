import Foundation

final class RequestRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var request: URLRequest?

    func record(_ request: URLRequest) {
        lock.withLock {
            self.request = request
        }
    }

    func recordedRequest() -> URLRequest? {
        lock.withLock { request }
    }
}
