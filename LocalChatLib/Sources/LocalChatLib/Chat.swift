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
    public var name: String = "Chat \(Date.now.formatted(date: .numeric, time: .shortened))"

    private var session: ChatSession // MLX session
    public let modelName: String
    init(session: ChatSession, modelName: String, id: UUID = UUID()) {
        self.modelName = modelName
        self.id = id

        // TODO: - change name according to first user message
        self.session = session
    }



    // TODO: - local chat messages persistent storage
    public var messages = [MLXLMCommon.Chat.Message]()
    public var lastErrorDescription: String?

    private var task: Task<Void, Error>?
    public var isBusy: Bool {
        task != nil
    }

    public func generateAnswer(from userInput: String) {
        guard task == nil else { return }
        lastErrorDescription = nil

        self.messages.append(.init(role: .user, content: userInput))
        self.messages.append(.init(role: .assistant, content: ""))
        let response = self.messages.count - 1

        self.task = Task {
            defer { self.task = nil }

            do {
                for try await partial in session.streamResponse(to: userInput) {
                    self.messages[response].content += partial
                }
            } catch is CancellationError {
                return
            } catch {
                lastErrorDescription = error.localizedDescription
                return
            }
        }
    }

    public func cancel() {
        task?.cancel()
        task = nil
    }
}

extension MLXLMCommon.Chat.Message: @retroactive Equatable {
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
