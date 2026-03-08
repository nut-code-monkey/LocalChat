//
//  ModelLoader.swift
//  LocalChatLib
//
//  Created by Максим Лунін on 07.03.2026.
//

import Foundation
import MLXLLM
import MLXLMCommon

@MainActor
@Observable
public class ModelLoader: Identifiable {
    public static let allModels: [ModelLoader] = [
        LLMRegistry.llama3_2_1B_4bit,
        LLMRegistry.gemma3_1B_qat_4bit,
        LLMRegistry.qwen3_0_6b_4bit

    ].map{
        ModelLoader(model: $0)
    }

    private var state: State = .notLoaded
    enum State {
        case notLoaded
        case loading(Task<ModelContainer, Error>)
        case loaded(ModelContainer)
    }

    public nonisolated let id: String
    public let model: ModelConfiguration
    public init(model: ModelConfiguration) {
        self.id = model.name
        self.model = model
    }

    public var name: String {
        get { model.name.components(separatedBy: "/").last ?? model.name }
    }
    public var progress = 0.0
    public var isLoaded: Bool {
        switch state {
        case .notLoaded, .loading: false
        case .loaded: true
        }
    }

    public func newChat(
        systemPrompt: String = String(localized: ""),
        generateParameters: GenerateParameters = GenerateParameters(temperature: 0.75)
    ) async throws -> Chat {
        let container = try await modelContainer()
        let chat = await Chat(
            session: ChatSession(
                container,
                instructions: systemPrompt,
                generateParameters: generateParameters
            ),
            modelName: name)
        ChatManager.shared.chats.append(chat)
        return chat
    }

    public func load() {
        Task { try? await modelContainer() }
    }

    // TODO: - model container cashing
    private func modelContainer() async throws -> ModelContainer {
        switch self.state {
        case .notLoaded:
            let task = Task {
                try await loadModelContainer(configuration: model) { value in
                    Task { @MainActor in
                        self.progress = value.fractionCompleted
                    }
                }
            }
            self.state = .loading(task)
            do {
                let container = try await task.value
                self.state = .loaded(container)
                return container
            } catch {
                self.state = .notLoaded
                self.progress = 0
                throw error
            }

        case .loading(let task):
            return try await task.value

        case .loaded(let container):
            return container
        }
    }
}

extension ModelLoader.State: Equatable, Hashable {
    static func == (lhs: ModelLoader.State, rhs: ModelLoader.State) -> Bool {
        switch (lhs, rhs) {
        case (.notLoaded, .notLoaded): true
        case (.loading, .loading): true
        case (.loaded, .loaded): true
        default: false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .notLoaded: hasher.combine(0)
        case .loading: hasher.combine(1)
        case .loaded: hasher.combine(2)
        }
    }
}

extension ModelLoader: @MainActor Equatable, @MainActor Hashable {
    public static func == (lhs: LocalChatLib.ModelLoader, rhs: LocalChatLib.ModelLoader) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
