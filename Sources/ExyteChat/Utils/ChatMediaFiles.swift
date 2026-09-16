//
//  ChatMediaFiles.swift
//

import Foundation

/// How the host app turns a media URL into a file the players can open.
///
/// Voice messages and videos are played with `AVPlayer`, which fetches a
/// remote URL itself, with a plain request. An app whose server authorizes
/// every media download cannot use that: the request arrives without
/// credentials and is refused, so nothing ever plays. Nor can it use it for
/// media it has to decrypt before playing.
///
/// Setting `resolve` hands those URLs to the app first. It returns a local
/// file to play, or nil when there is none, in which case nothing plays. When
/// `resolve` is not set, URLs are played as they are.
public enum ChatMediaFiles {
    /// A local file for a media URL, or nil when it cannot be had.
    public typealias Resolve = @Sendable (URL) async -> URL?

    public static var resolve: Resolve? {
        get { lock.withLock { stored } }
        set { lock.withLock { stored = newValue } }
    }

    /// The URL to hand to a player for `url`.
    static func playable(_ url: URL) async -> URL? {
        guard let resolve, !url.isFileURL else { return url }
        return await resolve(url)
    }

    nonisolated(unsafe) private static var stored: Resolve?
    private static let lock = NSLock()
}
