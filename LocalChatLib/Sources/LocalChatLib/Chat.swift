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
public class Chat: Identifiable {
    public let id: UUID

    // TODO: - persistent chat savings
    public var name: String = String(localized: "Chat \(Date.now)")

    // TODO: - make chats list persistent storage
    private static var currentAppSessionChats = [Chat]()
    public static func loadAllChats() async {
        currentAppSessionChats
    }

    private var session: ChatSession // MLX session
    public let modelName: String
    init(session: ChatSession, modelName: String, id: UUID = UUID()) {
        self.modelName = modelName
        self.id = id

        // TODO: - change name according to first user message
        self.session = session

        Chat.currentAppSessionChats.append(self)
    }



    // TODO: - local chat messages persistent storage
    public var messages = [MLXLMCommon.Chat.Message]()

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

extension MLXLMCommon.Chat.Message: Equatable {
    public static func == (lhs: MLXLMCommon.Chat.Message, rhs: MLXLMCommon.Chat.Message) -> Bool {
        lhs.role == rhs.role
        && lhs.content == rhs.content
        // TODO: - images / video support
//        && lhs.images == rhs.images
//        && lhs.videos == rhs.videos
    }
}

extension Chat: @MainActor Equatable, @MainActor Hashable {
    public static func == (lhs: Chat, rhs: Chat) -> Bool {
        lhs.messages == rhs.messages && lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
