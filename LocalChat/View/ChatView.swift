//
//  ChatView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI
import SpeziChat
import LocalChatLib
internal import MLXLMCommon

struct ChatView: View {
    @State var chat: LocalChatLib.Chat

    var body: some View {
        SpeziChat.ChatView(
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
                    if let userInput = messages.last, userInput.role == .user {
                        chat.generateAnswer(from: userInput.content)
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

#Preview {
    ChatSetupView(loader: ModelLoader.allModels[0])
        .frame(minHeight: 300)
}
