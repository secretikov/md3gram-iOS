import Foundation
import Combine

@MainActor
public class ChatDetailViewModel: ObservableObject {
    public let chatId: Int64
    @Published public var messages: [MessageItem] = []
    @Published public var isLoading: Bool = false

    private let tdlib: TDLibService
    private var cancellables = Set<AnyCancellable>()

    public init(chatId: Int64, tdlib: TDLibService = .shared) {
        self.chatId = chatId
        self.tdlib = tdlib
        bindUpdates()
    }

    private func bindUpdates() {
        tdlib.updatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                guard let self = self else { return }
                // Here we would filter updates for new messages in this chat
                if let type = update["@type"] as? String, type == "updateNewMessage" {
                    // Refresh or append message
                    // For mock purposes:
                    self.loadHistory()
                }
            }
            .store(in: &cancellables)
    }

    public func loadHistory() {
        isLoading = true
        Task {
            do {
                let query: [String: Any] = [
                    "@type": "getChatHistory",
                    "chat_id": chatId,
                    "from_message_id": 0,
                    "offset": 0,
                    "limit": 50,
                    "only_local": false
                ]

                let _ = try await tdlib.execute(query: query)

                // Mock message history
                let calendar = Calendar.current
                let today = Date()
                let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

                self.messages = [
                    MessageItem(id: 1, chatId: chatId, text: "Привет! Как дела?", isOutgoing: false, isRead: true, date: yesterday),
                    MessageItem(id: 2, chatId: chatId, text: "Всё отлично, спасибо!", isOutgoing: true, isRead: true, date: yesterday),
                    MessageItem(id: 3, chatId: chatId, text: "Что нового?", isOutgoing: false, isRead: true, date: today),
                    MessageItem(id: 4, chatId: chatId, text: "Работаю над MD3 клиентом.", isOutgoing: true, isRead: false, date: today)
                ]
            } catch {
                print("Failed to fetch message history")
            }
            self.isLoading = false
        }
    }

    public func sendMessage(text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        Task {
            do {
                let query: [String: Any] = [
                    "@type": "sendMessage",
                    "chat_id": chatId,
                    "input_message_content": [
                        "@type": "inputMessageText",
                        "text": [
                            "@type": "formattedText",
                            "text": text
                        ]
                    ]
                ]

                let _ = try await tdlib.execute(query: query)

                // Optimistically add message
                let newMessage = MessageItem(id: Int64.random(in: 1000...9999),
                                             chatId: chatId,
                                             text: text,
                                             isOutgoing: true,
                                             isRead: false,
                                             date: Date())
                self.messages.append(newMessage)

            } catch {
                print("Failed to send message")
            }
        }
    }
}
