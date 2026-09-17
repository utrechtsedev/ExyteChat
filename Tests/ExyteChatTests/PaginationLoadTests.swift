//
//  PaginationLoadTests.swift
//  Chat
//

import SwiftUI
import Testing
import UIKit

@testable import ExyteChat

/// When a list starts a load, and when it counts one as over.
@MainActor
struct PaginationLoadTests {

    /// Counts the loads a handler was asked for.
    final class Loads {
        var started = 0
        var finish: () async -> Void = {}
    }

    private func coordinator(
        rows ids: [String], older: PaginationHandler? = nil, newer: PaginationHandler? = nil
    ) -> (UIList<EmptyView>.Coordinator, UITableView) {
        var params = ChatCustomizationParameters()
        params.olderMessagesPaginationHandler = older
        params.newerMessagesPaginationHandler = newer
        let coordinator = UIList<EmptyView>.Coordinator(
            viewModel: ChatViewModel(),
            inputViewModel: InputViewModel(),
            isScrolledToBottom: .constant(true),
            isScrolledToTop: .constant(false),
            messageBuilder: { _ in EmptyView() },
            mainHeaderBuilder: nil,
            dateHeaderBuilder: nil,
            type: .conversation,
            sections: [],
            ids: [],
            chatParams: params,
            messageParams: MessageCustomizationParameters(),
            mainBackgroundColor: .clear
        )
        let user = User(id: "u", name: "U", avatarURL: nil, isCurrentUser: false)
        // Newest first, as the table has them.
        coordinator.sections = [MessagesSection(date: Date(timeIntervalSince1970: 0), rows: ids.map {
            MessageRow(
                message: Message(id: $0, user: user, createdAt: Date(timeIntervalSince1970: 0), text: $0),
                positionInUserGroup: .single, positionInMessagesSection: .single, commentsPosition: nil
            )
        })]
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 4_000), style: .plain)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        table.rowHeight = 44
        table.dataSource = coordinator
        table.delegate = coordinator
        // Drawn the way the list draws: inside an update, during which a row
        // coming into view starts nothing.
        coordinator.updateInProgress = true
        table.reloadData()
        table.layoutIfNeeded()
        coordinator.updateInProgress = false
        return (coordinator, table)
    }

    private func handler(_ loads: Loads, trigger: PaginationHandler.TriggerType = .cellIndex(0), more: Bool = true) -> PaginationHandler {
        PaginationHandler(triggerType: trigger, hasMoreToLoad: more, handleClosure: {
            loads.started += 1
            await loads.finish()
        })
    }

    private func settle() async {
        for _ in 0..<50 { await Task.yield() }
    }

    @Test func rowsThatAllFitStartTheirLoads() async {
        let older = Loads()
        let newer = Loads()
        let (coordinator, table) = coordinator(
            rows: ["3", "2", "1"], older: handler(older), newer: handler(newer)
        )
        #expect(Set((table.indexPathsForVisibleRows ?? []).map(\.row)) == [0, 1, 2])
        coordinator.paginateIfTriggerRowsShown(table)
        await settle()
        #expect(older.started == 1)
        #expect(newer.started == 1)
    }

    @Test func aTriggerOffScreenOrWithNothingMoreDoesNot() async {
        let nothingMore = Loads()
        let byPixels = Loads()
        let (coordinator, table) = coordinator(
            rows: ["3", "2", "1"],
            older: handler(nothingMore, more: false),
            newer: handler(byPixels, trigger: .pixels(0))
        )
        coordinator.paginateIfTriggerRowsShown(table)
        await settle()
        #expect(nothingMore.started == 0)
        #expect(byPixels.started == 0)

        let offScreen = Loads()
        let many = (1...400).map(String.init).reversed()
        let (tall, tallTable) = self.coordinator(rows: Array(many), older: handler(offScreen))
        tall.paginateIfTriggerRowsShown(tallTable)
        await settle()
        #expect(offScreen.started == 0)
    }

    @Test func aLoadThatChangedNothingIsOver() async {
        let loads = Loads()
        let (coordinator, table) = coordinator(rows: ["2", "1"], older: handler(loads))
        coordinator.performOlderPagination(table)
        await settle()
        #expect(loads.started == 1)
        #expect(!coordinator.paginationState.olderInProgress)
        // And a load already going is not started twice.
        let slow = Loads()
        var release: CheckedContinuation<Void, Never>?
        slow.finish = { await withCheckedContinuation { release = $0 } }
        let (busy, busyTable) = self.coordinator(rows: ["2", "1"], newer: handler(slow))
        busy.performNewerPagination(busyTable)
        await settle()
        #expect(busy.paginationState.newerInProgress)
        busy.paginateIfTriggerRowsShown(busyTable)
        await settle()
        #expect(slow.started == 1)
        release?.resume()
        await settle()
        #expect(!busy.paginationState.newerInProgress)
    }

    @Test func aLoadWhoseUpdateIsBeingAppliedIsEndedByIt() async {
        let loads = Loads()
        let (coordinator, table) = coordinator(rows: ["2", "1"], older: handler(loads))
        loads.finish = { coordinator.updateInProgress = true }
        coordinator.performOlderPagination(table)
        await settle()
        #expect(coordinator.paginationState.olderInProgress)

        let newer = Loads()
        let (other, otherTable) = self.coordinator(rows: ["2", "1"], newer: handler(newer))
        newer.finish = { other.updateInProgress = true }
        other.performNewerPagination(otherTable)
        await settle()
        #expect(other.paginationState.newerInProgress)
    }
}
