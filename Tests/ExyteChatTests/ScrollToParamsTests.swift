//
//  ScrollToParamsTests.swift
//  Chat
//

import Testing

@testable import ExyteChat

struct ScrollToParamsTests {

    @Test func askingAgainIsAnotherRequest() {
        let newest = ScrollToParams(.newestMessage)
        #expect(newest == newest)
        #expect(newest != ScrollToParams(.newestMessage))
        let message = ScrollToParams(messageID: "m", position: .middle)
        #expect(message == message)
        #expect(message != ScrollToParams(messageID: "m", position: .middle))
    }
}
