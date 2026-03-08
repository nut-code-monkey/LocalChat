//
//  ChatSetupView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI
import LocalChatLib

struct ChatSetupView: View {
    @State var loader: ModelLoader
    @State var result: Result<Chat, Error>? = nil
    var body: some View {
        VStack {
            switch result {

            case .success(let chat):
                ChatView(chat: chat)

            case .failure(let error):
                ContentUnavailableView { Text("Model loading error:") }
                description: { Text(error.localizedDescription) }
                actions: { Button("Retry", action: newChat) }

            case nil:
                ModelLoaderProgressView(
                    name: loader.name,
                    progress: $loader.progress
                )
            }
        }
        .task(newChat)
    }

    private func newChat() {
        Task { @MainActor in
            do {
                result = nil
                result = .success(try await loader.newChat())
            } catch {
                result = .failure(error)
            }
        }
    }
}

#Preview {
    ChatSetupView(loader: ModelLoader.allModels[0])
}
