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
    @State private var setupTask: Task<Void, Never>?
    @State private var requestID = UUID()

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
        .onDisappear {
            setupTask?.cancel()
            setupTask = nil
        }
    }

    private func newChat() {
        setupTask?.cancel()
        result = nil

        let currentRequestID = UUID()
        requestID = currentRequestID

        setupTask = Task { @MainActor in
            do {
                let chat = try await loader.newChat()
                guard requestID == currentRequestID else { return }
                result = .success(chat)
            } catch {
                guard requestID == currentRequestID else { return }
                result = .failure(error)
            }
        }
    }
}

#Preview {
    ChatSetupView(loader: ModelLoader.allModels[0])
}
