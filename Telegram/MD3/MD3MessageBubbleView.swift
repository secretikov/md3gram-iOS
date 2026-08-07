import SwiftUI

public struct Message: Identifiable {
    public let id = UUID()
    public let formattedText: FormattedText
    public let isMine: Bool
    public let time: String
    public let isRead: Bool

    public init(formattedText: FormattedText, isMine: Bool, time: String, isRead: Bool) {
        self.formattedText = formattedText
        self.isMine = isMine
        self.time = time
        self.isRead = isRead
    }
}

public struct MD3MessageBubbleView: View {
    public let message: Message
    @Environment(\.md3Theme) var theme

    // State to toggle spoiler visibility for this specific bubble if needed
    @State private var isSpoilerRevealed = false

    public init(message: Message) {
        self.message = message
    }

    // We compute the attributed string so we can modify the spoiler style dynamically
    private var attributedText: AttributedString {
        var attrStr = FormattedTextParser.parse(formattedText: message.formattedText, theme: theme)
        // Adjust spoiler styling based on state
        for entity in message.formattedText.entities where entity.type == .spoiler {
            if let stringRange = Range(entity.range, in: message.formattedText.text),
               let start = AttributedString.Index(stringRange.lowerBound, within: attrStr),
               let end = AttributedString.Index(stringRange.upperBound, within: attrStr) {
                let attrRange = start..<end

                if isSpoilerRevealed {
                    // Reset to normal text colors but perhaps keep a subtle background to indicate it was a spoiler
                    attrStr[attrRange].foregroundColor = message.isMine ? theme.onPrimaryContainer : theme.onSecondaryContainer
                    attrStr[attrRange].backgroundColor = theme.surfaceVariant.opacity(0.3)
                    attrStr[attrRange].link = nil // Remove link so it doesn't stay tappable as a URL
                } else {
                    // Hidden state
                    // Keep the outline block style defined in parser
                }
            }
        }
        return attrStr
    }

    public var body: some View {
        HStack {
            if message.isMine { Spacer() }

            VStack(alignment: message.isMine ? .trailing : .leading, spacing: 4) {
                Text(attributedText)
                    .font(.body)
                    .foregroundColor(message.isMine ? theme.onPrimaryContainer : theme.onSecondaryContainer)
                    .environment(\.openURL, OpenURLAction { url in
                        if url.scheme == "spoiler" {
                            withAnimation {
                                isSpoilerRevealed = true
                            }
                            return .handled
                        }
                        return .systemAction(url)
                    })

                HStack(spacing: 4) {
                    Text(message.time)
                        .font(.caption2)
                        .foregroundColor((message.isMine ? theme.onPrimaryContainer : theme.onSecondaryContainer).opacity(0.7))

                    if message.isMine {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.caption2)
                            .foregroundColor(theme.primary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(message.isMine ? theme.primaryContainer : theme.secondaryContainer)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                TailShape(isMine: message.isMine)
                    .fill(message.isMine ? theme.primaryContainer : theme.secondaryContainer)
                    .frame(width: 16, height: 16)
                    .offset(x: message.isMine ? 8 : -8, y: 0),
                alignment: message.isMine ? .bottomTrailing : .bottomLeading
            )
            .padding(message.isMine ? .trailing : .leading, 12)

            if !message.isMine { Spacer() }
        }
    }
}

public struct TailShape: Shape {
    public var isMine: Bool

    public init(isMine: Bool) {
        self.isMine = isMine
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        if isMine {
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 12))
        } else {
            path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 12))
        }
        path.closeSubpath()
        return path
    }
}
