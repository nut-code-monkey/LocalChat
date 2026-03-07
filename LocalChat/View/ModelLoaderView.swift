//
//  ModelLoaderView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI
import LocalChatLib

struct ModelLoaderView: View {
    @State var loader: ModelLoader
    @State var chat: LocalChat? = nil
    @State var errorMessage: String? = nil
    var body: some View {
        VStack {
            if !loader.isLoaded {
                ModelLoaderProgressView(
                    name: loader.name,
                    progress: $loader.progress
                )

            } else {
                if let chat {
                    LocalChatView(chat: chat)

                } else if let errorMessage {
                    ModelLoaderRetryView(
                        errorMessage: errorMessage,
                        action: getChat
                    )
                }
            }
        }
        .frame(minWidth: 300, minHeight: 300)
        .task { await getChat() }
    }

    private func getChat() async {
        do {
            chat = try await loader.localChat(systemPrompt: "")
            errorMessage = nil
            print("get chat")
        } catch {
            chat = nil
            errorMessage = error.localizedDescription
            print("error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ModelLoaderView(loader: ModelLoader.allModels[0])
}
