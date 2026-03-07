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
public class ModelLoader {
    static let allModels: [String: ModelLoader] = [
        LLMRegistry.llama3_2_1B_4bit,
        LLMRegistry.gemma3_1B_qat_4bit,
        LLMRegistry.qwen3_0_6b_4bit

    ].reduce(into: [:]) { dict, model in
        dict[model.name] = ModelLoader(model: model)
    }

    enum State {
        case notLoaded
        case loading(Task<ModelContainer, Error>)
        case loaded(ModelContainer)
    }

    private var state: State = .notLoaded

    private let model: ModelConfiguration
    public init(model: ModelConfiguration) {
        self.model = model
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
