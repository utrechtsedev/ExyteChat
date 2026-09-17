//
//  LinkPreviewCard.swift
//  Chat
//

import ImageIO
import SwiftUI
import UIKit

/// A message's link preview, drawn from what the message carries. The link is
/// opened only when the card is tapped. A tap gesture, as the other tappable
/// parts of a bubble have, so a long press still opens the message menu.
struct LinkPreviewCard: View {

    @Environment(\.chatTheme) private var theme
    @Environment(\.openURL) private var openURL

    let preview: Message.LinkPreview
    let userType: UserType

    private static let imageSide: CGFloat = 56

    private var textColor: Color { theme.colors.messageText(userType) }

    var body: some View {
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
        .onTapGesture {
            openURL(preview.url)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isLink)
        .accessibilityAction {
            openURL(preview.url)
        }
    }
}

/// Preview images, decoded once for as long as memory allows: a message is
/// drawn again on every change to the list.
@MainActor
private enum LinkPreviewImages {
    private static let cache = NSCache<Key, UIImage>()

    /// The image's bytes as a cache key, hashed whole. `NSData` hashes only
    /// its first bytes, which every JPEG from the same encoder shares.
    private final class Key: NSObject {
        let data: Data
        private let digest: Int

        init(_ data: Data) {
            self.data = data
            var hasher = Hasher()
            hasher.combine(data)
            digest = hasher.finalize()
        }

        override var hash: Int { digest }

        override func isEqual(_ object: Any?) -> Bool {
            (object as? Key)?.data == data
        }
    }

    /// Decoded at most this many pixels on the longer side: the card draws
    /// the image small, whatever size its bytes say it is.
    static let maxPixelSide = 256

    static func image(from data: Data?) -> UIImage? {
        guard let data else { return nil }
        let key = Key(data)
        if let cached = cache.object(forKey: key) { return cached }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSide,
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary),
              let decoded = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
        else { return nil }
        let image = UIImage(cgImage: decoded)
        cache.setObject(image, forKey: key)
        return image
    }
}
