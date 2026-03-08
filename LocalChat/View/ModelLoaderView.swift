//
//  ModelLoaderView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI
import LocalChatLib

enum NewChat {
    case chat(LocalChat)
    case error(String)
}

struct ModelLoaderView: View {
    @State var loader: ModelLoader
    @State var result: Result<LocalChat, Error>? = nil
    var body: some View {
        VStack {
            switch result {

            case let .success(chat):
                LocalChatView(chat: chat)

            case let .failure(error):
                ModelLoaderRetryView(
                    errorMessage: error.localizedDescription,
                    action: newChat
                )

            case nil:
                ModelLoaderProgressView(
                    name: loader.name,
                    progress: $loader.progress
                )
            }
        }
        .task { await newChat() }
    }

    private func newChat() async {
        do {
            result = nil
            result =
                .success(try await loader.newChat())
        } catch {
            result = .failure(error)
        }
    }
}

#Preview {
    ModelLoaderView(loader: ModelLoader.allModels[0])
}
