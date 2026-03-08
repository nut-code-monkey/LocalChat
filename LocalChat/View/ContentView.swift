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
                ModelSelectionView(view: .full)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("New Chat", systemImage: "plus.circle") {
                                isSelectModels = true
                            }
                        }
                    }

                    .navigationDestination(for: Navigation.Chat.self) { route in
                        switch route {
                        case .loader(let loader):
                            ChatSetupView(loader: loader)
                        case .existing(let chat):
                            ChatView(chat: chat)
                        }
                    }
            }
        }
        .navigationTitle("Models")
        .sheet(isPresented: $isSelectModels) {
            ModelSelectionView(view: .compact)
        }
        .environment(\.navigation, navigation)
    }
}

#Preview {
    ContentView()
}
