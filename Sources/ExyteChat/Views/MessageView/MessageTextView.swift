//
//  SwiftUIView.swift
//  
//
//  Created by Alex.M on 07.07.2022.
//

import SwiftUI

@MainActor
struct MessageTextView: View {

    @Environment(\.chatTheme) private var theme

    let attributedText: AttributedString
    /// The message's own preview of a link in the text, if it has one.
    let linkPreview: Message.LinkPreview?
    let userType: UserType
    let params: MessageCustomizationParameters

    var body: some View {
        if !attributedText.characters.isEmpty {
            VStack(alignment: .leading) {
                if let linkPreview {
                    LinkPreviewCard(preview: linkPreview, userType: userType)
                }

                Text(attributedText)
                    .foregroundStyle(theme.colors.messageText(userType))
            }
            .font(Font(params.font as CTFont))
        }
    }
}

struct MessageTextView_Previews: PreviewProvider {
    static var previews: some View {
        MessageTextView(
            attributedText: "Look at [this website](https://example.org)",
            linkPreview: nil,
            userType: .other,
            params: MessageCustomizationParameters()
        )
        MessageTextView(
            attributedText: "Look at https://example.org",
            linkPreview: Message.LinkPreview(
                url: URL(string: "https://example.org")!,
                title: "Example Domain",
                summary: "This domain is for use in illustrative examples in documents."
            ),
            userType: .current,
            params: MessageCustomizationParameters()
        )
    }
}
