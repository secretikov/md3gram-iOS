import SwiftUI

public struct MD3SearchBar: View {
    @Binding var text: String
    @Environment(\.md3Theme) var theme

    public var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(theme.onSurfaceVariant)
            TextField("Search", text: $text)
                .foregroundColor(theme.onSurface)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.surfaceVariant)
        .clipShape(Capsule())
    }
}

public struct MD3ChatListView: View {
    @Environment(\.md3Theme) var theme
    @StateObject private var viewModel = ChatListViewModel()
    @State private var selectedTab: Int = 0
    @State private var searchText: String = ""

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Top Search Bar
                VStack(spacing: 12) {
                    HStack {
                        Text("Chats")
                            .font(.title)
                            .foregroundColor(theme.onBackground)
                        Spacer()
                    }
                    MD3SearchBar(text: $searchText)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(theme.background)

                // Chat List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.chats) { chat in
                            ChatRow(chat: chat)
                            Divider()
                                .background(theme.surfaceVariant)
                                .padding(.leading, 80)
                        }
                    }
                }
                .background(theme.background)
                .overlay {
                    if viewModel.isLoading && viewModel.chats.isEmpty {
                        ProgressView()
                    }
                }

                // Bottom Navigation
                MD3NavigationBar(selectedTab: $selectedTab)
            }

            // FAB
            MD3FAB(iconName: "pencil") {
                print("New Chat Tapped")
            }
            .padding(.trailing, 16)
            .padding(.bottom, 100) // Above navigation bar
        }
        .onAppear {
            viewModel.loadChats()
        }
    }
}

public struct ChatRow: View {
    let chat: ChatItem
    @Environment(\.md3Theme) var theme

    public var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(theme.primaryContainer)
                .frame(width: 56, height: 56)
                .overlay(
                    Text(String(chat.title.prefix(1)))
                        .font(.title2)
                        .foregroundColor(theme.onPrimaryContainer)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.title)
                        .font(.headline)
                        .foregroundColor(theme.onSurface)

                    Spacer()

                    if chat.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundColor(theme.onSurfaceVariant)
                    }
                }

                HStack {
                    Text(chat.lastMessagePreview)
                        .font(.subheadline)
                        .foregroundColor(theme.onSurfaceVariant)
                        .lineLimit(1)

                    Spacer()

                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.caption2.bold())
                            .foregroundColor(theme.onPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(theme.primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.background)
    }
}
