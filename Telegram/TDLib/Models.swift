import Foundation

public struct ChatItem: Identifiable, Equatable {
    public let id: Int64
    public let title: String
    public let unreadCount: Int
    public let lastMessagePreview: String
    public let isPinned: Bool

    public init(id: Int64, title: String, unreadCount: Int, lastMessagePreview: String, isPinned: Bool) {
        self.id = id
        self.title = title
        self.unreadCount = unreadCount
        self.lastMessagePreview = lastMessagePreview
        self.isPinned = isPinned
    }
}

public struct MessageItem: Identifiable, Equatable {
    public let id: Int64
    public let chatId: Int64
    public let text: String
    public let isOutgoing: Bool
    public let isRead: Bool
    public let date: Date

    // You could also link this to FormattedText from the previous step
    // public let formattedText: FormattedText

    public init(id: Int64, chatId: Int64, text: String, isOutgoing: Bool, isRead: Bool, date: Date) {
        self.id = id
        self.chatId = chatId
        self.text = text
        self.isOutgoing = isOutgoing
        self.isRead = isRead
        self.date = date
    }
}
