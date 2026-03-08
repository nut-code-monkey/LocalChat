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
