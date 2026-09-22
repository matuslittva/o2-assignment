import SwiftUI

struct ScratchCardView: View {
    let state: ScratchCard.State

    private var code: String? {
        switch state {
        case .unscratched:
            nil
        case let .scratched(code), let .activated(code):
            code
        }
    }

    private var title: String {
        switch state {
        case .unscratched:
            "Ready to scratch"
        case .scratched:
            "Code revealed"
        case .activated:
            "Card activated"
        }
    }

    private var systemImage: String {
        switch state {
        case .unscratched:
            "rectangle.dashed"
        case .scratched:
            "number"
        case .activated:
            "checkmark.seal.fill"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                Spacer()
                Image(systemName: systemImage)
                    .font(.title2)
                    .contentTransition(.symbolEffect(.replace))
            }

            Spacer(minLength: 8)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                    .contentTransition(.opacity)

                if let code {
                    Text(code)
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    Text("Your activation code is hidden")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .foregroundStyle(.white)
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 210, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.blue, .indigo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .shadow(color: .indigo.opacity(0.2), radius: 18, y: 10)
        .animation(.snappy(duration: 0.35), value: state)
        .accessibilityElement(children: .combine)
    }
}
