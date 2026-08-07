import Foundation
import Combine

@MainActor
public class ChatListViewModel: ObservableObject {
    @Published public var chats: [ChatItem] = []
    @Published public var isLoading: Bool = false

    private let tdlib: TDLibService
    private var cancellables = Set<AnyCancellable>()

    public init(tdlib: TDLibService = .shared) {
        self.tdlib = tdlib
        bindUpdates()
    }

    private func bindUpdates() {
        tdlib.updatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                // Handle new messages or chat list updates here to refresh list
                if let type = update["@type"] as? String, type == "updateNewMessage" {
                    self?.loadChats()
                }
            }
            .store(in: &cancellables)
    }

    public func loadChats() {
        isLoading = true
        Task {
            do {
                let query: [String: Any] = [
                    "@type": "getChats",
                    "chat_list": ["@type": "chatListMain"],
                    "limit": 20
                ]

                let _ = try await tdlib.execute(query: query)
                // In a real app, TDLib returns a list of chat IDs, and you fetch details for each

                // For demonstration, mock some chats
                self.chats = [
                    ChatItem(id: 1, title: "Павел Дуров", unreadCount: 0, lastMessagePreview: "Новое обновление Telegram", isPinned: true),
                    ChatItem(id: 2, title: "iOS Developers", unreadCount: 5, lastMessagePreview: "Кто смотрел WWDC?", isPinned: false),
                    ChatItem(id: 3, title: "Дизайн Команда", unreadCount: 0, lastMessagePreview: "Переходим на Material You", isPinned: false)
                ]
            } catch {
                print("Failed to fetch chats")
            }
            self.isLoading = false
        }
    }
}
