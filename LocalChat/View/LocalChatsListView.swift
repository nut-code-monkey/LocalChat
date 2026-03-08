//
//  LocalChatsListView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI
import LocalChatLib

struct LocalChatsListView: View {
    @State var chats: [LocalChat]? = nil
    let newChatAction: () -> Void
    let selectChatAction: (LocalChat) -> Void

    var body: some View {

        if let chats {
            List(chats, id: \.id) { chat in
                Text(chat.name)
            }
        } else {
            Text("Loading...")
        }
    }
}

#Preview {
    LocalChatsListView(
        newChatAction: {},
        selectChatAction: {chat in
        }
    )
}
