import SwiftUI

struct AppRootView: View {
    private let container: AppContainer
    @StateObject private var homeViewModel: HomeViewModel
    @State private var path: [Destination] = []

    init(container: AppContainer) {
        self.container = container
        _homeViewModel = StateObject(wrappedValue: container.makeHomeViewModel())
    }

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                viewModel: homeViewModel,
                onScratchCard: {
                    path.append(.scratch)
                },
                onActivateCard: {
                    path.append(.activation)
                }
            )
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .scratch:
                    container.makeScratchView(
                        card: homeViewModel.card,
                        onCardChanged: homeViewModel.update
                    )
                case .activation:
                    container.makeActivationView(
                        card: homeViewModel.card,
                        onCardChanged: homeViewModel.update
                    )
                }
            }
        }
        .task {
            await homeViewModel.load()
        }
    }
}

private extension AppRootView {
    enum Destination: Hashable {
        case scratch
        case activation
    }
}
