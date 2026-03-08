//
//  LocalChatModels.swift
//  LocalChatLib
//
//  Created by Максим Лунін on 07.03.2026.
//

import Foundation
import MLXLMCommon

@MainActor
@Observable
public class LocalChat: Identifiable {
    public let id: UUID

    private var _name: String = String(localized: "New chat")
    public var name: String {
        get { _name }
        set { _name = name } // TODO: - persistent chat savings
    }

    // TODO: - make chats list persistent storage
    private static var currentAppSessionChats = [LocalChat]()
    public static func allChats() async throws -> [LocalChat] {
        currentAppSessionChats
    }

    private var session: ChatSession // MLX session
    init(session: ChatSession, id: UUID = UUID()) {
        self.id = id

        // TODO: - change name according to first user message
        self.session = session

        LocalChat.currentAppSessionChats.append(self)
    }

    // TODO: - local chat messages persistent storage
    public var messages = [Chat.Message]()

    private var task: Task<Void, Error>?
    public var isBusy: Bool {
        task != nil
    }

    public func generateAnswer(from userInput: String) {
        guard task == nil else { return }

        self.messages.append(.init(role: .user, content: userInput))
        self.messages.append(.init(role: .assistant, content: ""))
        let response = self.messages.count - 1

        self.task = Task {
            for try await partial in session.streamResponse(to: userInput) {
                self.messages[response].content += partial
            }
            self.task = nil
        }
    }

    public func cancel() {
        task?.cancel()
    }
}

extension Chat.Message: Equatable {
    public static func == (lhs: MLXLMCommon.Chat.Message, rhs: MLXLMCommon.Chat.Message) -> Bool {
        lhs.role == rhs.role
        && lhs.content == rhs.content
        // TODO: - images / video support
//        && lhs.images == rhs.images
//        && lhs.videos == rhs.videos
    }
}

extension LocalChat: @MainActor Equatable {
    public static func == (lhs: LocalChat, rhs: LocalChat) -> Bool {
        lhs.messages == rhs.messages && lhs.id == rhs.id
    }
}
