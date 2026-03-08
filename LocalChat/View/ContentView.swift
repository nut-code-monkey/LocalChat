//
//  ContentView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI
import LocalChatLib

struct ContentView: View {
    @State private var navigation = Navigation()
    @State private var isSelectModels: Bool = false

    var body: some View {
        NavigationSplitView {
            ChatsListView { isSelectModels = true }
        } detail: {
            NavigationStack(path: $navigation.path) {
                List(ModelLoader.allModels) { model in
                    ProgressView(value: model.progress) {
                        Text(model.name)
                    } currentValueLabel: {
                        Text(model.progress, format: .percent)
                    }
                    .progressViewStyle(.linear)
                }

                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("New Chat", systemImage: "plus.circle") {
                            isSelectModels = true
                        }
                    }
                }

                .navigationDestination(for: LocalChat.self) { chat in
                    ChatView(chat: chat)
                }

                .navigationDestination(for: ModelLoader.self) { loader in
                    ChatSetupView(loader: loader)
                }
            }
        }
        .navigationTitle("Models loaded:")
        .sheet(isPresented: $isSelectModels) {
            ModelSelectionView()
        }
        .environment(\.navigation, navigation)
    }

}

#Preview {
    ContentView()
}
