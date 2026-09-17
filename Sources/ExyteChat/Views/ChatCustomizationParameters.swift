//
//  ChatCustomizationParameters.swift
//  Chat
//
//  Created by Alisa Mylnikova on 02.04.2026.
//

import SwiftUI
import ExyteMediaPicker

struct ChatCustomizationParameters {
    var isListAboveInputView: Bool = true
    var showScrollToBottomButton: Bool = true
    /// The scroll-to-bottom button shows at the bottom of the list too: the
    /// list does not hold the newest messages.
    var showsScrollToBottomButtonAtBottom: Bool = false
    /// What the scroll-to-bottom button does instead of scrolling to the
    /// newest message the list holds.
    var scrollToBottomAction: (() -> Void)?
    var showNetworkConnectionProblem: Bool = false
    var showDateHeaders: Bool = true
    var isScrollEnabled: Bool = true
    var autoFocusTextInputOnChatOpen: Bool = false
    var showMessageMenuOnLongPress: Bool = true
    var showShareAttachmentButton: Bool = true
    var showLastReadIndicator: Bool = false
    var keyboardDismissMode: UIScrollView.KeyboardDismissMode = .none
    var messageMenuAnimationDuration: CGFloat = 0.3
    var contentInsets: UIEdgeInsets = .zero

    var scrollToParams: ScrollToParams?
    var onContentOffsetChange: ((CGFloat) -> Void)? // Internal → External
    var onWillDisplayCell: ((Message) -> Void)?
    var onTransactionReady: ((TableUpdateTransaction) -> Void)?
    var onLiveLocationBroadcast: ((LiveLocationBroadcastEvent) -> Void)?

    var olderMessagesPaginationHandler: PaginationHandler?
    var newerMessagesPaginationHandler: PaginationHandler?
    var localization = ChatLocalization.defaultLocalization // these can be localized in the Localizable.strings files
    var reactionDelegate: ReactionDelegate?
    var listSwipeActions = ListSwipeActions()
}

public struct ScrollToParams: Equatable {
    public enum ScrollTo: Equatable {
        case messageID(messageID: String, position: UITableView.ScrollPosition, offset: CGFloat)
        case tableOffset(CGFloat)
        case newestMessage
        case oldestMessage
    }

    let scrollTo: ScrollTo
    /// Tells two requests for the same place apart: a request is something
    /// that happens, so asking again scrolls again, even to where the list
    /// was sent last time.
    private let id = UUID()

    public init(messageID: String, position: UITableView.ScrollPosition, offset: CGFloat = 0) {
        self.scrollTo = .messageID(messageID: messageID, position: position, offset: offset)
    }

    public init(offset: CGFloat) {
        self.scrollTo = .tableOffset(offset)
    }

    public init(_ scrollTo: ScrollTo) {
        self.scrollTo = scrollTo
    }
}

struct MessageCustomizationParameters {
    var showTimeView = true
    var showUsername = false
    var font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
    var timeFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 10))

    // avatar
    var showAvatar = true
    var avatarSize: CGFloat = 32
    var tapAvatarClosure: ChatView.TapAvatarClosure?
    var avatarBuilder: ((User)->(AnyView))?
}

struct InputViewCustomizationParameters {
    var externalInputText: String? // External → Internal
    var onInputTextChange: ((String) -> Void)? // Internal → External
    var availableInputs: [AvailableInputType] = [.text, .audio, .media]
    var recorderSettings = RecorderSettings()
    var audioRecordingMode: AudioRecordingMode = .holdToRecord
    var mediaPickerParameters = MediaPickerParameters()
    var photoPickerBackend: PhotoPickerBackend = .custom
}

public typealias MediaPickerParameters = ExyteMediaPicker.MediaPickerCutomizationParameters

/// Which photo/video picker is presented when the user taps to attach media.
public enum PhotoPickerBackend: Sendable, Equatable {
    /// ExyteMediaPicker fully customizable built-in media picker (default)
    case custom
    /// Apple's native PhotosPicker
    /// Camera capture always uses the ExyteMediaPicker regardless of this setting.
    case system
}
