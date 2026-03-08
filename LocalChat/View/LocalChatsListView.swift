//
//  LocalChatsListView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI
import LocalChatLib

struct LocalChatsListView: View {
    @Environment(\.navigation) private var navigation

    let newChatAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(
                "New chat",
                systemImage: "plus.circle",
                action: newChatAction
            )
            Text("Active chats:")
            ForEach(ChatManager.shared.chats, id: \.id) { chat in
                Button(chat.name) {
                    navigation.push(chat: chat)
                }
            }
            Spacer()
        }
        .padding()
        .task { ChatManager.shared.updateChatsList() }
    }
}

#Preview {
    @Previewable @State var navigation = Navigation()
    NavigationStack(path: $navigation.path) {
        LocalChatsListView {
            print("New chat button clicked")
        }
    }
    .environment(\.navigation, navigation)
}
