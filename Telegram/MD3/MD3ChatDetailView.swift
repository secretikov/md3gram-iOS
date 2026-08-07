import SwiftUI

public struct MD3ChatDetailView: View {
    @Environment(\.md3Theme) var theme
    @StateObject private var viewModel: ChatDetailViewModel
    @State private var inputText: String = ""

    public let chat: ChatItem

    public init(chat: ChatItem) {
        self.chat = chat
        _viewModel = StateObject(wrappedValue: ChatDetailViewModel(chatId: chat.id))
    }

    private var groupedMessages: [(Date, [MessageItem])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: viewModel.messages) { message in
            calendar.startOfDay(for: message.date)
        }
        return grouped.sorted { $0.key < $1.key }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    public var body: some View {
        VStack(spacing: 0) {
            MD3TopAppBar(
                title: chat.title,
                subtitle: "Online", // Or fetch from chat data
                avatarText: String(chat.title.prefix(1)),
                isOnline: true,
                onBack: {
                    // Handle back navigation
                }
            )

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(groupedMessages, id: \.0) { date, messages in
                            // Date Header
                            Text(dateFormatter.string(from: date))
                                .font(.caption2.bold())
                                .foregroundColor(theme.onSurfaceVariant)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(theme.surfaceVariant.opacity(0.5))
                                .clipShape(Capsule())
                                .padding(.vertical, 8)

                            // Messages
                            ForEach(messages) { message in
                                MD3MessageBubbleView(message: Message(
                                    formattedText: FormattedText(text: message.text, entities: []), // For now, plain text mapping
                                    isMine: message.isOutgoing,
                                    time: timeFormatter.string(from: message.date),
                                    isRead: message.isRead
                                ))
                                .id(message.id)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
                .background(theme.background)
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // MD3 Input Field
            MD3MessageInputBar(text: $inputText) { text in
                viewModel.sendMessage(text: text)
                inputText = ""
            }
        }
        .onAppear {
            viewModel.loadHistory()
        }
        .navigationBarHidden(true)
    }
}

public struct MD3MessageInputBar: View {
    @Binding var text: String
    @Environment(\.md3Theme) var theme
    public let onSend: (String) -> Void

    public var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Button(action: {}) {
                Image(systemName: "paperclip")
                    .font(.title2)
                    .foregroundColor(theme.onSurfaceVariant)
                    .padding(8)
            }

            HStack(alignment: .bottom, spacing: 8) {
                TextField("Message", text: $text, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .foregroundColor(theme.onSurface)

                Button(action: {}) {
                    Image(systemName: "face.smiling")
                        .font(.title2)
                        .foregroundColor(theme.onSurfaceVariant)
                        .padding(.trailing, 10)
                        .padding(.bottom, 8)
                }
            }
            .background(theme.surfaceVariant)
            .clipShape(RoundedRectangle(cornerRadius: 24))

            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button(action: {}) {
                    Image(systemName: "mic.fill")
                        .font(.title2)
                        .foregroundColor(theme.onPrimaryContainer)
                        .frame(width: 44, height: 44)
                        .background(theme.primaryContainer)
                        .clipShape(Circle())
                }
            } else {
                Button(action: { onSend(text) }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(theme.onPrimary)
                        .frame(width: 44, height: 44)
                        .background(theme.primary)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(theme.surface)
        // Add shadow for MD3 Elevation
        .shadow(color: theme.outline.opacity(0.1), radius: 4, x: 0, y: -2)
    }
}
