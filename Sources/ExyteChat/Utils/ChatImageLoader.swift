//
//  ChatImageLoader.swift
//

import Foundation
import Kingfisher

/// How the host app fetches remote images, when it has to fetch them itself.
///
/// Avatars and attachments are ordinary URLs to this library, and it loads
/// them with a plain request. An app whose server authorizes every media
/// download cannot use that: the request arrives without credentials and comes
/// back 401, so every avatar is a grey circle and every photo a blank cell.
///
/// Setting `load` hands those fetches back to the app, which can sign them.
/// Returning nil leaves the placeholder in place. Results are kept in memory by
/// this library, so the app is asked once per image while it runs; keeping
/// them on disk is the app's business.
public enum ChatImageLoader {
    /// Fetch the bytes for a URL, or nil when they cannot be had.
    public typealias Load = @Sendable (URL) async -> Data?

    public static var load: Load? {
        get { lock.withLock { stored } }
        set { lock.withLock { stored = newValue } }
    }

    /// Forget the images kept under these cache keys (an attachment's
    /// `cacheKey`, or its URL when it has none): their message is gone.
    public static func removeCachedImages(forKeys keys: [String]) async {
        for key in keys {
            try? await KingfisherManager.shared.cache.removeImage(forKey: key)
        }
    }

    /// Forget every image this library keeps, in memory and on disk: the
    /// account that saw them signed out.
    public static func removeAllCachedImages() async {
        await KingfisherManager.shared.cache.clearCache()
    }

    nonisolated(unsafe) private static var stored: Load?
    private static let lock = NSLock()
}

private extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        lock()
        defer { unlock() }
        return body()
    }
}
