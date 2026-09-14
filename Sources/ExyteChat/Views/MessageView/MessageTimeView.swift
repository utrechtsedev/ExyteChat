//
//  Created by Alex.M on 08.07.2022.
//

import SwiftUI

struct MessageTimeView: View {
    @Environment(\.chatTheme) var theme

    let text: String
    let userType: UserType
    /// Shown after the time, inside the bubble. Nil for messages from others.
    var status: Message.Status? = nil
    var onRetry: () -> Void = {}

    var body: some View {
        HStack(spacing: MessageStatusIcon.spacing) {
            Text(text)
            if let status {
                MessageStatusIcon(status: status, color: theme.colors.messageTimeText(userType), onRetry: onRetry)
            }
        }
        .foregroundColor(theme.colors.messageTimeText(userType))
    }
}

struct MessageTimeWithCapsuleView: View {
    let text: String
    let isCurrentUser: Bool
    var status: Message.Status? = nil
    var onRetry: () -> Void = {}

    var body: some View {
        HStack(spacing: MessageStatusIcon.spacing) {
            Text(text)
            if let status {
                MessageStatusIcon(status: status, color: .white, onRetry: onRetry)
            }
        }
        .foregroundColor(.white)
        .opacity(0.8)
        .padding(.top, 4)
        .padding(.bottom, 4)
        .padding(.horizontal, 8)
        .background {
            Capsule()
                .foregroundColor(.black.opacity(0.4))
        }
    }
}

/// The delivery status drawn next to the time, the way Telegram shows it:
/// inside the bubble and in the time's own colour, so it stays readable on
/// any bubble colour. Only an error keeps its own colour, because it asks for
/// a tap.
struct MessageStatusIcon: View {
    @Environment(\.chatTheme) private var theme

    /// Fixed, so the time view's width can be computed before layout.
    static let width: CGFloat = 16
    static let height: CGFloat = 11
    static let spacing: CGFloat = 3

    let status: Message.Status
    let color: Color
    let onRetry: () -> Void

    var body: some View {
        switch status {
        case .sending:
            icon(theme.images.message.sending, color: color)
        case .sent:
            icon(theme.images.message.sent, color: color)
        case .delivered:
            icon(theme.images.message.delivered, color: color)
        case .readBy:
            icon(theme.images.message.read, color: color)
        case .error:
            Button(action: onRetry) {
                icon(theme.images.message.error, color: theme.colors.statusError)
            }
        }
    }

    private func icon(_ image: Image, color: Color) -> some View {
        image
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(color)
            .frame(width: Self.width, height: Self.height)
    }
}
