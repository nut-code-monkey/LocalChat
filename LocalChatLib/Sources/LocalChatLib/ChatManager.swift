//
//  SwiftUIView.swift
//  LocalChatLib
//
//  Created by Максим Лунін on 08.03.2026.
//

import Foundation

@MainActor
@Observable
public final class ChatManager {
    public static var shared = ChatManager()

    public var chats: [LocalChat] = []

    private init() {}

    public func updateChatsList() {
        // TODO: - init from persistent storage
    }
}

