//
//  PaginationTargetTests.swift
//  Chat
//

import Foundation
import Testing

@testable import ExyteChat

struct PaginationTargetTests {

    private func rows(_ ids: [String]) -> [MessageRow] {
        let user = User(id: "u", name: "U", avatarURL: nil, isCurrentUser: false)
        return ids.map {
            MessageRow(
                message: Message(id: $0, user: user, createdAt: Date(timeIntervalSince1970: 0), text: $0),
                positionInUserGroup: .single, positionInMessagesSection: .single, commentsPosition: nil
            )
        }
    }

    @Test func aLoadStartsTheGivenNumberOfRowsBeforeTheEnd() {
        // Newest first, as the table has them.
        let list = rows(["9", "8", "7", "6", "5", "4", "3", "2", "1"])
        #expect(list.paginationTarget(rowsIn: 0) == "9")
        #expect(list.paginationTarget(rowsIn: 3) == "6")
        #expect(list.reversed().paginationTarget(rowsIn: 0) == "1")
        #expect(list.reversed().paginationTarget(rowsIn: 3) == "4")
        // Fewer rows than that: the far end.
        #expect(list.paginationTarget(rowsIn: 20) == "1")
        #expect(list.reversed().paginationTarget(rowsIn: 20) == "9")
        #expect(rows([]).paginationTarget(rowsIn: 3) == nil)
    }

    @Test func aTriggerByPixelsSitsAtNoRow() {
        #expect(PaginationHandler(triggerType: .cellIndex(8), handleClosure: {}).rowsFromEnd == 8)
        #expect(PaginationHandler(triggerType: .cellIndex(-1), handleClosure: {}).rowsFromEnd == 0)
        #expect(PaginationHandler(triggerType: .pixels(40), handleClosure: {}).rowsFromEnd == nil)
    }
}
