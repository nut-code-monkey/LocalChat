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
    @State private var lastHandledUserInput: String?

    var body: some View {
        SpeziChat.ChatView(
            Binding<[ChatEntity]>(get: messages, set: setMessages),
            disableInput: chat.isBusy,
        )
        .onDisappear(perform: chat.cancel)
        .alert(
            "Generation error",
            isPresented: Binding(
                get: { chat.lastErrorDescription != nil },
                set: { isPresented in
                    if !isPresented {
                        chat.lastErrorDescription = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                chat.lastErrorDescription = nil
            }
        } message: {
            Text(chat.lastErrorDescription ?? "Unknown error")
        }
        .navigationTitle("\(chat.name) with \(chat.modelName)")
    }

    private func messages() -> [ChatEntity] {
        chat.messages.map { .init(role: $0.role.speziChatRole, content: $0.content) }
    }

    private func setMessages(_ messages: [ChatEntity]) {
        guard let userInput = messages.last, userInput.role == .user else { return }
        guard userInput.content != lastHandledUserInput else { return }

        lastHandledUserInput = userInput.content
        chat.generateAnswer(from: userInput.content)
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
