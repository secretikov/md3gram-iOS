import SwiftUI

public struct MD3TopAppBar: View {
    @Environment(\.md3Theme) var theme
    public let title: String
    public let subtitle: String?
    public let avatarText: String
    public let isOnline: Bool
    public let onBack: () -> Void

    public init(title: String, subtitle: String? = nil, avatarText: String, isOnline: Bool, onBack: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.avatarText = avatarText
        self.isOnline = isOnline
        self.onBack = onBack
    }

    public var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(theme.onSurface)
                    .padding(.trailing, 4)
            }

            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(theme.primaryContainer)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(avatarText)
                            .font(.headline)
                            .foregroundColor(theme.onPrimaryContainer)
                    )

                if isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(theme.surface, lineWidth: 2)
                        )
                        .offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(theme.onSurface)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(theme.onSurfaceVariant)
                }
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .foregroundColor(theme.onSurfaceVariant)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.surface)
    }
}
