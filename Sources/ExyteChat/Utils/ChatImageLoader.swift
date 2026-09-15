//
//  ChatImageLoader.swift
//

import Foundation

/// How the host app fetches remote images, when it has to fetch them itself.
///
/// Avatars and attachments are ordinary URLs to this library, and it loads
/// them with a plain request. An app whose server authorizes every media
/// download cannot use that: the request arrives without credentials and comes
/// back 401, so every avatar is a grey circle and every photo a blank cell.
///
/// Setting `load` hands those fetches back to the app, which can sign them.
/// Returning nil leaves the placeholder in place. Results are still cached by
/// this library, so the app is asked once per image.
public enum ChatImageLoader {
    /// Fetch the bytes for a URL, or nil when they cannot be had.
    public typealias Load = @Sendable (URL) async -> Data?

    public static var load: Load? {
        get { lock.withLock { stored } }
        set { lock.withLock { stored = newValue } }
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
