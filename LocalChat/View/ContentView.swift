//
//  ContentView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI
import LocalChatLib

@Observable
final class Navigation {
    var path = NavigationPath()

    enum Chat: Hashable {
        case loader(ModelLoader)
        case existing(LocalChat)
    }

    func push(loader: ModelLoader) {
        path.append(Chat.loader(loader))
    }

    func push(chat: LocalChat) {
        path.append(Chat.existing(chat))
    }
}

extension EnvironmentValues {
    private struct NavigationKey: EnvironmentKey {
        static let defaultValue = Navigation()
    }

    var navigation: Navigation {
        get { self[NavigationKey.self] }
        set { self[NavigationKey.self] = newValue }
    }
}

struct ContentView: View {
    @State private var navigation = Navigation()

    @State private var isSelectModels: Bool = false

    var body: some View {

        NavigationSplitView {
            LocalChatsListView{ isSelectModels = true }
        } detail: {
            NavigationStack(path: $navigation.path) {
                ModelSelectionView(info: .full)
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
                        ModelLoaderView(loader: loader)
                    case .existing(let chat):
                        LocalChatView(chat: chat)
                    }
                }
            }
        }
        .navigationTitle("Models")
        .sheet(isPresented: $isSelectModels) {
            ModelSelectionView(info: .compact)
        }
        .environment(\.navigation, navigation)
    }
}

#Preview {
    ContentView()
}
