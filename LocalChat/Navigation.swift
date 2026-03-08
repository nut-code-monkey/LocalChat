//
//  Navigation.swift
//  LocalChat
//
//  Created by Максим Лунін on 08.03.2026.
//

import SwiftUI
import LocalChatLib

@Observable
final class Navigation {
    var path = NavigationPath()

    func newChat(with loader: ModelLoader) {
        path.append(loader)
    }

    func existing(chat: LocalChat) {
        path.append(chat)
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
