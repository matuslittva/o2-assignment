import SwiftUI

@main
struct O2ScratchCardApp: App {
    private let container = AppContainer.live()

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
                .tint(.blue)
        }
    }
}
