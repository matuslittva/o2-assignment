struct ActivationResponseConverter: Sendable {
    func convert(_ response: ActivationResponse) throws -> Version {
        let rawComponents = response.ios.split(
            separator: ".",
            omittingEmptySubsequences: false
        )
        let components = rawComponents.compactMap { Int($0) }

        guard
            (2...3).contains(rawComponents.count),
            components.count == rawComponents.count,
            components.allSatisfy({ $0 >= 0 })
        else {
            throw NetworkingError.invalidPayload
        }

        return Version(
            major: components[0],
            minor: components[1],
            patch: components.count == 3 ? components[2] : 0
        )
    }
}
