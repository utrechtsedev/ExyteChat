//
//  MessageLinkPreview.swift
//  Chat
//

import Foundation

public extension Message {

    /// What a link in the message looks like, supplied with the message.
    ///
    /// The library draws it from these values alone and never fetches the
    /// link: a reader's device that fetched it would tell the linked site who
    /// read the message, and from where. Whoever makes the preview, usually
    /// the sender's device, is the only one that contacts the site.
    struct LinkPreview: Hashable, Sendable {
        /// Opened when the preview is tapped. Its host is shown as the site.
        public var url: URL
        public var title: String?
        public var summary: String?
        /// A small image in any format `UIImage` reads.
        public var imageData: Data?

        public init(url: URL, title: String? = nil, summary: String? = nil, imageData: Data? = nil) {
            self.url = url
            self.title = title
            self.summary = summary
            self.imageData = imageData
        }
    }
}

extension Message.LinkPreview {
    /// The site, as the link names it: never taken from what the preview says
    /// about itself.
    var site: String? {
        guard let host = url.host(percentEncoded: false), !host.isEmpty else { return nil }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}
