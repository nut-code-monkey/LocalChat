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

    enum State {
        case notLoaded
        case loading(Task<ModelContainer, Error>)
        case loaded(ModelContainer)
    }

    private var state: State = .notLoaded

    public let model: ModelConfiguration
    public init(model: ModelConfiguration) {
        self.model = model
    }

    public var name: String {
        get { model.name }
    }
    public var progress = 0.0
    public var isLoaded: Bool {
        switch state {
        case .notLoaded, .loading: false
        case .loaded: true
        }
    }

    public func localChat(
        systemPrompt: String,
        generateParameters: GenerateParameters = GenerateParameters(temperature: 0.75)
    ) async throws -> LocalChat {
        let container = try await modelContainer()
        let session = ChatSession(
            container,
            instructions: systemPrompt,
            generateParameters: generateParameters
        )

        // TODO: - local chat messages persistent storage
        return LocalChat(session: session)
    }

    public func load() {
        Task { try? await modelContainer() }
    }

    // TODO: - model container caching
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
            let container = try await task.value

            self.state = .loaded(container)
            return container

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
        lhs.name == rhs.name &&
        lhs.state == rhs.state &&
        lhs.progress == rhs.progress
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(state)
        hasher.combine(progress)
    }
}
