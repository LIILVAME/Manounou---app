import SwiftUI

// MARK: - Theme

private enum MessagesTheme {
    enum Colors {
        static let brand = Color(red: 250/255, green: 66/255, blue: 112/255)
        static let paper = Color(red: 244/255, green: 242/255, blue: 236/255)
        static let ink = Color(red: 24/255, green: 24/255, blue: 28/255)
        static let muted = Color(red: 140/255, green: 140/255, blue: 148/255)
        static let parentBlue = Color(red: 59/255, green: 130/255, blue: 246/255)
        static let onlineGreen = Color(red: 34/255, green: 197/255, blue: 94/255)
    }
}

// MARK: - Data Models

struct DemoConversation: Identifiable, Hashable {
    let id: UUID
    let name: String
    let role: ParticipantRole
    let lastMessage: String
    let timeLabel: String
    let unreadCount: Int
    var isOnline: Bool

    enum ParticipantRole: String {
        case nounou = "Nounou"
        case coParent = "Co-parent"
    }

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first.map { String($0) } }
        return letters.joined()
    }

    var avatarColor: Color {
        switch role {
        case .nounou: return MessagesTheme.Colors.brand
        case .coParent: return MessagesTheme.Colors.parentBlue
        }
    }
}

struct DemoMessage: Identifiable {
    let id: UUID
    let text: String
    let isFromMe: Bool
    let timestamp: Date
    let dayGroup: DayGroup

    enum DayGroup: String {
        case yesterday = "Hier"
        case today = "Aujourd'hui"
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
}

// MARK: - Demo Data

private extension DemoConversation {
    static let all: [DemoConversation] = [
        DemoConversation(
            id: UUID(),
            name: "Fatou Koné",
            role: .nounou,
            lastMessage: "Awa a bien mangé 🍎",
            timeLabel: "il y a 5 min",
            unreadCount: 2,
            isOnline: true
        ),
        DemoConversation(
            id: UUID(),
            name: "Thomas Dupont",
            role: .coParent,
            lastMessage: "D'accord pour vendredi !",
            timeLabel: "hier",
            unreadCount: 0,
            isOnline: false
        )
    ]
}

private extension DemoMessage {
    static func fatouThread() -> [DemoMessage] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!

        func ts(_ base: Date, h: Int, m: Int) -> Date {
            cal.date(bySettingHour: h, minute: m, second: 0, of: base)!
        }

        return [
            DemoMessage(
                id: UUID(),
                text: "Awa a bien mangé, sieste de 13h à 14h30 ✓",
                isFromMe: false,
                timestamp: ts(yesterday, h: 14, m: 30),
                dayGroup: .yesterday
            ),
            DemoMessage(
                id: UUID(),
                text: "Super merci Fatou !",
                isFromMe: true,
                timestamp: ts(yesterday, h: 14, m: 35),
                dayGroup: .yesterday
            ),
            DemoMessage(
                id: UUID(),
                text: "Awa est arrivée, tout va bien 😊",
                isFromMe: false,
                timestamp: ts(today, h: 9, m: 15),
                dayGroup: .today
            ),
            DemoMessage(
                id: UUID(),
                text: "Awa a bien mangé 🍎",
                isFromMe: false,
                timestamp: ts(today, h: 12, m: 48),
                dayGroup: .today
            )
        ]
    }
}

// MARK: - Root MessagesView

struct MessagesView: View {
    @State private var selectedConversation: DemoConversation? = nil
    @State private var conversations: [DemoConversation] = DemoConversation.all

    var body: some View {
        NavigationStack {
            ZStack {
                MessagesTheme.Colors.paper
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom nav title area
                    HStack {
                        Text("Messages")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundColor(MessagesTheme.Colors.ink)
                        Spacer()
                        Button {
                            // Compose new message
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(MessagesTheme.Colors.brand)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                    // Conversation list
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(conversations) { conversation in
                                ConversationRowView(conversation: conversation)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedConversation = conversation
                                    }

                                if conversation.id != conversations.last?.id {
                                    Divider()
                                        .padding(.leading, 76)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                    }

                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: Binding(
                get: { selectedConversation != nil },
                set: { if !$0 { selectedConversation = nil } }
            )) {
                if let conversation = selectedConversation {
                    ThreadView(conversation: conversation)
                }
            }
        }
    }
}

// MARK: - Conversation Row

private struct ConversationRowView: View {
    let conversation: DemoConversation

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                AvatarView(
                    initials: conversation.initials,
                    color: conversation.avatarColor,
                    size: 50
                )

                if conversation.isOnline {
                    Circle()
                        .fill(MessagesTheme.Colors.onlineGreen)
                        .frame(width: 13, height: 13)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: 1, y: 1)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    Text(conversation.name)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundColor(MessagesTheme.Colors.ink)
                        .lineLimit(1)

                    RoleBadgeView(role: conversation.role)

                    Spacer()

                    Text(conversation.timeLabel)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(MessagesTheme.Colors.muted)
                }

                HStack(alignment: .center, spacing: 0) {
                    Text(conversation.lastMessage)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(
                            conversation.unreadCount > 0
                                ? MessagesTheme.Colors.ink
                                : MessagesTheme.Colors.muted
                        )
                        .lineLimit(1)
                        .fontWeight(conversation.unreadCount > 0 ? .medium : .regular)

                    Spacer()

                    if conversation.unreadCount > 0 {
                        UnreadBadgeView(count: conversation.unreadCount)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Role Badge

private struct RoleBadgeView: View {
    let role: DemoConversation.ParticipantRole

    private var badgeColor: Color {
        switch role {
        case .nounou: return MessagesTheme.Colors.brand.opacity(0.12)
        case .coParent: return MessagesTheme.Colors.parentBlue.opacity(0.12)
        }
    }

    private var textColor: Color {
        switch role {
        case .nounou: return MessagesTheme.Colors.brand
        case .coParent: return MessagesTheme.Colors.parentBlue
        }
    }

    var body: some View {
        Text(role.rawValue)
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundColor(textColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(badgeColor)
            .cornerRadius(6)
    }
}

// MARK: - Unread Badge

private struct UnreadBadgeView: View {
    let count: Int

    var body: some View {
        Text("\(count)")
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(minWidth: 20, minHeight: 20)
            .padding(.horizontal, count > 9 ? 6 : 0)
            .background(MessagesTheme.Colors.brand)
            .clipShape(Capsule())
    }
}

// MARK: - Avatar View

private struct AvatarView: View {
    let initials: String
    let color: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: size, height: size)

            Text(initials)
                .font(.system(size: size * 0.32, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
    }
}

// MARK: - Thread View

struct ThreadView: View {
    let conversation: DemoConversation

    @State private var messageText: String = ""
    @State private var messages: [DemoMessage] = []
    @State private var scrollProxy: ScrollViewProxy? = nil
    @Environment(\.dismiss) private var dismiss

    private let quickReplies = ["👍", "Oui !", "Merci Fatou 🙏", "J'arrive"]

    var body: some View {
        ZStack {
            MessagesTheme.Colors.paper
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom header
                ThreadHeaderView(
                    conversation: conversation,
                    onBack: { dismiss() }
                )

                Divider()

                // Messages scroll
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(groupedMessages(), id: \.dayGroup) { group in
                                DaySeparatorView(label: group.dayGroup.rawValue)

                                ForEach(group.messages) { message in
                                    MessageBubbleView(message: message)
                                        .id(message.id)
                                }
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .onAppear {
                        scrollProxy = proxy
                        scrollToBottom(proxy: proxy, animated: false)
                    }
                    .onChange(of: messages.count) { _ in
                        if let proxy = scrollProxy {
                            scrollToBottom(proxy: proxy, animated: true)
                        }
                    }
                }

                // Quick replies
                QuickRepliesView(quickReplies: quickReplies) { reply in
                    sendQuickReply(reply)
                }

                // Composer
                ComposerView(
                    text: $messageText,
                    onSend: sendMessage
                )
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            messages = DemoMessage.fatouThread()
        }
    }

    // MARK: Helpers

    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool) {
        guard let lastId = messages.last?.id else { return }
        if animated {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(lastId, anchor: .bottom)
        }
    }

    private func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newMessage = DemoMessage(
            id: UUID(),
            text: trimmed,
            isFromMe: true,
            timestamp: Date(),
            dayGroup: .today
        )
        messages.append(newMessage)
        messageText = ""

        if let proxy = scrollProxy {
            scrollToBottom(proxy: proxy, animated: true)
        }
    }

    private func sendQuickReply(_ reply: String) {
        let newMessage = DemoMessage(
            id: UUID(),
            text: reply,
            isFromMe: true,
            timestamp: Date(),
            dayGroup: .today
        )
        messages.append(newMessage)

        if let proxy = scrollProxy {
            scrollToBottom(proxy: proxy, animated: true)
        }
    }

    private struct MessageGroup {
        let dayGroup: DemoMessage.DayGroup
        let messages: [DemoMessage]
    }

    private func groupedMessages() -> [MessageGroup] {
        var result: [MessageGroup] = []
        var current: DemoMessage.DayGroup? = nil
        var currentMessages: [DemoMessage] = []

        for message in messages {
            if message.dayGroup != current {
                if let existing = current, !currentMessages.isEmpty {
                    result.append(MessageGroup(dayGroup: existing, messages: currentMessages))
                }
                current = message.dayGroup
                currentMessages = [message]
            } else {
                currentMessages.append(message)
            }
        }

        if let last = current, !currentMessages.isEmpty {
            result.append(MessageGroup(dayGroup: last, messages: currentMessages))
        }

        return result
    }
}

// MARK: - Thread Header

private struct ThreadHeaderView: View {
    let conversation: DemoConversation
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Retour")
                        .font(.system(size: 17, design: .rounded))
                }
                .foregroundColor(MessagesTheme.Colors.brand)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(conversation.name)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundColor(MessagesTheme.Colors.ink)

                HStack(spacing: 4) {
                    if conversation.isOnline {
                        Circle()
                            .fill(MessagesTheme.Colors.onlineGreen)
                            .frame(width: 8, height: 8)
                        Text("En ligne")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(MessagesTheme.Colors.onlineGreen)
                    } else {
                        Text("Hors ligne")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(MessagesTheme.Colors.muted)
                    }
                }
            }

            Spacer()

            AvatarView(
                initials: conversation.initials,
                color: conversation.avatarColor,
                size: 36
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - Day Separator

private struct DaySeparatorView: View {
    let label: String

    var body: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(MessagesTheme.Colors.muted.opacity(0.3))
                .frame(height: 1)

            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(MessagesTheme.Colors.muted)
                .fixedSize()

            Rectangle()
                .fill(MessagesTheme.Colors.muted.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

// MARK: - Message Bubble

private struct MessageBubbleView: View {
    let message: DemoMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.isFromMe { Spacer(minLength: 60) }

            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 3) {
                Text(message.text)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(message.isFromMe ? .white : MessagesTheme.Colors.ink)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isFromMe
                            ? MessagesTheme.Colors.brand
                            : Color.white
                    )
                    .cornerRadius(18, corners: message.isFromMe
                        ? [.topLeft, .topRight, .bottomLeft]
                        : [.topLeft, .topRight, .bottomRight]
                    )
                    .shadow(
                        color: Color.black.opacity(message.isFromMe ? 0 : 0.06),
                        radius: 4,
                        x: 0,
                        y: 2
                    )

                Text(message.timeString)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(MessagesTheme.Colors.muted)
                    .padding(.horizontal, 4)
            }

            if !message.isFromMe { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 3)
    }
}

// MARK: - Corner Radius Helper

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

private struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Quick Replies

private struct QuickRepliesView: View {
    let quickReplies: [String]
    let onTap: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(quickReplies, id: \.self) { reply in
                    Button {
                        onTap(reply)
                    } label: {
                        Text(reply)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(MessagesTheme.Colors.brand)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(MessagesTheme.Colors.brand.opacity(0.1))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(MessagesTheme.Colors.brand.opacity(0.25), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.white)
    }
}

// MARK: - Composer

private struct ComposerView: View {
    @Binding var text: String
    let onSend: () -> Void
    @FocusState private var isFocused: Bool

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 10) {
            TextField("Écrire un message…", text: $text, axis: .vertical)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(MessagesTheme.Colors.ink)
                .lineLimit(1...5)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(MessagesTheme.Colors.paper)
                .cornerRadius(22)
                .focused($isFocused)
                .onSubmit {
                    if canSend { onSend() }
                }

            Button {
                onSend()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(canSend ? MessagesTheme.Colors.brand : MessagesTheme.Colors.muted.opacity(0.4))
                    )
            }
            .disabled(!canSend)
            .animation(.easeInOut(duration: 0.15), value: canSend)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -2)
        )
    }
}

// MARK: - Preview

#Preview {
    MessagesView()
}
