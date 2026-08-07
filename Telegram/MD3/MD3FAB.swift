import SwiftUI

public struct MD3FAB: View {
    @Environment(\.md3Theme) var theme
    public let iconName: String
    public let action: () -> Void

    public init(iconName: String, action: @escaping () -> Void) {
        self.iconName = iconName
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(theme.onPrimaryContainer)
                .frame(width: 56, height: 56)
                .background(theme.primaryContainer)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: theme.outline.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
}
