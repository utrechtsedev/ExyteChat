//
//  MessageLinkPreviewTests.swift
//  Chat
//

import Foundation
import Testing

@testable import ExyteChat

struct MessageLinkPreviewTests {

    @Test func theSiteIsTheLinksOwnHost() {
        let preview = { (link: String) in Message.LinkPreview(url: URL(string: link)!, title: "Says anything") }
        #expect(preview("https://www.example.com/a").site == "example.com")
        #expect(preview("https://news.example.com").site == "news.example.com")
        #expect(preview("https://user@bank.example.evil.example/").site == "bank.example.evil.example")
        // An international name shows in its ASCII form, so a name made of
        // look-alike letters cannot pass for another site.
        #expect(preview("https://bücher.example/").site == "xn--bcher-kva.example")
        #expect(preview("https://аpple.example/").site == "xn--pple-43d.example")
    }

    @Test func aMessageWithAnotherPreviewIsAnotherMessage() {
        let user = User(id: "u", name: "U", avatarURL: nil, isCurrentUser: false)
        let date = Date(timeIntervalSince1970: 0)
        let first = Message.LinkPreview(url: URL(string: "https://example.com")!, title: "One")
        var second = first
        second.imageData = Data([0xFF, 0xD8, 0xFF])
        let message = { (preview: Message.LinkPreview?) in
            Message(id: "m", user: user, createdAt: date, text: "https://example.com", linkPreview: preview)
        }
        #expect(message(first) == message(first))
        #expect(message(first) != message(second))
        #expect(message(first) != message(nil))
    }
}
