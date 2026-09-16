//
//  LinkPreviewCard.swift
//  Chat
//

import SwiftUI
import UIKit

/// A message's link preview, drawn from what the message carries. The link is
/// opened only when the card is tapped.
struct LinkPreviewCard: View {

    @Environment(\.chatTheme) private var theme
    @Environment(\.openURL) private var openURL

    let preview: Message.LinkPreview
    let userType: UserType

    private static let imageSide: CGFloat = 56

    private var textColor: Color { theme.colors.messageText(userType) }

    var body: some View {
        Button {
            openURL(preview.url)
        } label: {
            HStack(alignment: .top, spacing: 8) {
                if let image = LinkPreviewImages.image(from: preview.imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: Self.imageSide, height: Self.imageSide)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .accessibilityHidden(true)
                }
                VStack(alignment: .leading, spacing: 2) {
                    if let title = preview.title {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(2)
                    }
                    if let summary = preview.summary {
                        Text(summary)
                            .font(.caption)
                            .lineLimit(3)
                    }
                    if let site = preview.site {
                        Text(site)
                            .font(.caption2)
                            .opacity(0.7)
                            .lineLimit(1)
                    }
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(8)
            .background(textColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
            .foregroundStyle(textColor)
            .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isLink)
    }
}

/// Preview images, decoded once for as long as memory allows: a message is
/// drawn again on every change to the list.
@MainActor
private enum LinkPreviewImages {
    private static let cache = NSCache<NSData, UIImage>()

    static func image(from data: Data?) -> UIImage? {
        guard let data else { return nil }
        let key = data as NSData
        if let cached = cache.object(forKey: key) { return cached }
        guard let image = UIImage(data: data) else { return nil }
        cache.setObject(image, forKey: key)
        return image
    }
}
