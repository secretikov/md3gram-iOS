import Foundation
import SwiftUI

public enum TextEntityType {
    case bold
    case italic
    case code // monospace
    case textUrl(url: URL)
    case spoiler
}

public struct TextEntity {
    public let type: TextEntityType
    public let range: NSRange

    public init(type: TextEntityType, range: NSRange) {
        self.type = type
        self.range = range
    }
}

public struct FormattedText {
    public let text: String
    public let entities: [TextEntity]

    public init(text: String, entities: [TextEntity]) {
        self.text = text
        self.entities = entities
    }
}

public class FormattedTextParser {
    public static func parse(formattedText: FormattedText, theme: MD3ColorScheme) -> AttributedString {
        var attributedString = AttributedString(formattedText.text)

        // Note: For custom backgrounds like code blocks or blur effects (spoilers),
        // pure AttributedString in SwiftUI might have limitations.
        // We can use standard attributes and handle specialized views if needed,
        // but since iOS 15+ AttributedString has basic formatting:

        for entity in formattedText.entities {
            // Convert NSRange to AttributedString.Index accurately
            if let stringRange = Range(entity.range, in: formattedText.text),
               let start = AttributedString.Index(stringRange.lowerBound, within: attributedString),
               let end = AttributedString.Index(stringRange.upperBound, within: attributedString) {
                let attrRange = start..<end

                switch entity.type {
                case .bold:
                    attributedString[attrRange].inlinePresentationIntent = .stronglyEmphasized
                case .italic:
                    attributedString[attrRange].inlinePresentationIntent = .emphasized
                case .code:
                    // Monospace font and background color
                    attributedString[attrRange].font = .system(.body, design: .monospaced)
                    attributedString[attrRange].backgroundColor = theme.surfaceVariant
                case .textUrl(let url):
                    attributedString[attrRange].link = url
                    attributedString[attrRange].foregroundColor = theme.primary
                    attributedString[attrRange].underlineStyle = .single
                case .spoiler:
                    // Use a custom link attribute scheme to handle spoiler taps in SwiftUI Text
                    // so we can distinguish it from normal urls
                    if let spoilerURL = URL(string: "spoiler://reveal") {
                        attributedString[attrRange].link = spoilerURL
                        // Styling will be handled based on state in the view, but as a base:
                        attributedString[attrRange].backgroundColor = theme.outline
                        attributedString[attrRange].foregroundColor = theme.outline
                    }
                }
            }
        }

        return attributedString
    }
}
