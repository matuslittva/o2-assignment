# O2 Scratch Card

A small SwiftUI implementation of the O2 iOS home assignment.

## Requirements

- Xcode 26 or newer
- iOS 17.0 or newer
- Swift 6 language mode with complete strict-concurrency checking

## Architecture

The app follows a small, feature-oriented layered architecture:

- `Domain` contains entities, repository contracts and use cases.
- `Data` contains repositories and a reusable networking client. The HTTP client owns transport,
  status-code validation and decoding errors; endpoint repositories only build requests and map responses.
- `Presentation` contains one `@MainActor` observable ViewModel per screen.
- `Views` contains passive SwiftUI views and reusable view components.
- `App` is the composition root. `AppContainer` retains only shared low-level dependencies,
  while explicit `make…UseCase()` and `make…ViewModel()` factories assemble feature graphs.

`ScratchCardLocalRepository` is an actor-isolated source of truth. ViewModels use
classic `ObservableObject` and `@Published` state. Feature ViewModels publish a successful use-case
result locally and forward it to the root ViewModel, keeping screens synchronized without streams
or repository subscriptions.

## Concurrency decisions

- Scratching is exposed as one async ViewModel operation. Tapping the button changes a local
  action flag and `ScratchView` runs the operation through SwiftUI `.task(id:)`. The task inherits
  the destination's lifetime, so SwiftUI cancels it automatically when the user navigates back.
  Cancellation propagates through `Task.sleep` and `Task.checkCancellation`; no UUID is generated,
  nothing is saved to the repository and no error alert is presented.
- Activation intentionally has different ownership. `PrimaryActionButton` bridges its synchronous
  button action to an unstructured task. The task is not tied to `ActivationView` disappearing and
  retains the feature-scoped ViewModel until the request and state update complete. Navigating back
  therefore does not cancel activation, as required by the assignment.
- Repository and service contracts conform to `Sendable`; mutable local data is actor-isolated,
  while ViewModel state remains main-actor isolated.

## Assignment behavior

- The card starts as `unscratched` and supports the required transitions to `scratched` and then
  `activated`.
- The home screen always displays the current card state and provides navigation to both feature
  screens.
- Scratching is allowed only for an unscratched card, waits two seconds, generates a random UUID
  and persists the revealed code. Leaving the screen before completion cancels the operation.
- Activation is allowed only after the code has been revealed. It sends a `GET` request to
  `https://api.o2.sk/version` with the revealed value in the `code` query parameter and requires no
  authentication.
- A response version strictly greater than `6.1` activates the card. A version at or below the
  threshold presents an error alert and leaves the card unchanged.
- Leaving the activation screen does not cancel the request. The shared repository and root
  ViewModel are updated when the operation completes.

## Dependency lifetime

- `AppContainer`: one instance for the application lifetime; owns the shared card and activation repositories.
- `HomeViewModel`: created by `AppRootView` and retained with `@StateObject` for the root lifetime.
- `ScratchViewModel` and `ActivationViewModel`: created by factories when their destination opens
  and owned by that destination through `@StateObject`; injected children use `@ObservedObject`.
- Use cases: lightweight values created by the corresponding factory and injected into a ViewModel.

## Version comparison

`ActivationResponseConverter` validates the API's `ios` string and maps its two or three numeric
components to the simple `Version` entity. `APIActivationRepository` returns that entity, so
`ActivateScratchCardUseCase` only applies the assignment rule: activation requires a version
strictly greater than `6.1.0`. Invalid response values fail as networking payload errors and do not
change the card.

## Tests

The `O2ScratchCardTests` target covers:

- scratch and activation use cases, including cancellation and invalid transitions,
- activation response conversion and threshold comparison,
- local and API repository behavior,
- Home, Scratch and Activation ViewModels.

Run the shared `O2ScratchCard` scheme with `Command-U` in Xcode.
