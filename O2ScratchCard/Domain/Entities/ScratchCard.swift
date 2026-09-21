struct ScratchCard: Equatable, Sendable {
    enum State: Equatable, Sendable {
        case unscratched
        case scratched(code: String)
        case activated(code: String)
    }

    let state: State

    init(state: State = .unscratched) {
        self.state = state
    }
}
