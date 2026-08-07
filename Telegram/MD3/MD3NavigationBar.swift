import SwiftUI

public struct MD3NavigationBar: View {
    @Binding public var selectedTab: Int
    @Environment(\.md3Theme) var theme

    public let tabs: [String]
    public let icons: [String]

    public init(selectedTab: Binding<Int>, tabs: [String] = ["Чаты", "Каналы", "Звонки", "Настройки"], icons: [String] = ["message.fill", "megaphone.fill", "phone.fill", "gearshape.fill"]) {
        self._selectedTab = selectedTab
        self.tabs = tabs
        self.icons = icons
    }

    public var body: some View {
        HStack {
            ForEach(0..<tabs.count, id: \.self) { index in
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: icons[index])
                        .font(.system(size: 20))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 20)
                        .background(selectedTab == index ? theme.secondaryContainer : Color.clear)
                        .clipShape(Capsule())
                        .foregroundColor(selectedTab == index ? theme.onSecondaryContainer : theme.onSurfaceVariant)

                    Text(tabs[index])
                        .font(.system(size: 12, weight: selectedTab == index ? .semibold : .regular))
                        .foregroundColor(selectedTab == index ? theme.onSurface : theme.onSurfaceVariant)
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index }
                }
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .background(theme.surfaceVariant.opacity(0.4))
    }
}
