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
public class LocalChat {
    private var session: ChatSession // MLX session
    init(session: ChatSession) {
        self.session = session
    }

    // TODO: - local chat messages persistent storage
    public var messages = [Chat.Message]()

    private var task: Task<Void, Error>?
    public var isBusy: Bool {
        task != nil
    }

    public func generate(from userInput: String) {
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

