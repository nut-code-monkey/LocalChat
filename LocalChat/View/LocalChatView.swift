//
//  LocalChatView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI
import SpeziChat
import LocalChatLib
internal import MLXLMCommon

extension MLXLMCommon.Chat.Message.Role {
    var speziChatRole: ChatEntity.Role {
        switch self {
        case .user: .user
        case .assistant: .assistant
        case .system: .hidden(type: .unknown)
        case .tool: .hidden(type: .unknown)
        }
    }
}

extension ChatEntity {
    init(with message: MLXLMCommon.Chat.Message) {
        self.init(role: message.role.speziChatRole, content: message.content)
    }
}

struct LocalChatView: View {
    @State var chat: LocalChat

    var body: some View {
        ChatView(
            Binding<SpeziChat.Chat>(
                get: {
                    chat.messages.map { message in
                        ChatEntity(
                            role: message.role.speziChatRole,
                            content: message.content
                        )
                    }
                },
                set: { messages in
                    if let message = messages.last, message.role == .user {
                        chat.generateAnswer(from: message.content)
                    }
                }
            ),
            disableInput: chat.isBusy,
        )
        .onDisappear {
            chat.cancel()
        }
        .navigationTitle("\(chat.name) with \(chat.modelName)")
    }
}

#Preview {
    ModelLoaderView(loader: ModelLoader.allModels[0])
        .frame(minHeight: 300)
}
