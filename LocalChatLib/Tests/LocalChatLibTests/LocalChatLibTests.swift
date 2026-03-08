import Foundation
import Testing
import MLXLLM
import MLXLMCommon
@testable import LocalChatLib

private enum StubError: Error {
    case failed
}

private func makeStream(
    chunks: [String],
    delayNanoseconds: UInt64 = 0,
    failure: Error? = nil
) -> AsyncThrowingStream<String, Error> {
    AsyncThrowingStream { continuation in
        let task = Task {
            do {
                for chunk in chunks {
                    if delayNanoseconds > 0 {
                        try await Task.sleep(nanoseconds: delayNanoseconds)
                    }
                    continuation.yield(chunk)
                }
                if let failure {
                    continuation.finish(throwing: failure)
                } else {
                    continuation.finish()
                }
            } catch {
                continuation.finish(throwing: error)
            }
        }

        continuation.onTermination = { _ in
            task.cancel()
        }
    }
}

@MainActor
private func waitUntilNotBusy(_ chat: LocalChatLib.Chat, timeoutNanoseconds: UInt64 = 1_000_000_000) async {
    let step: UInt64 = 10_000_000
    var elapsed: UInt64 = 0

    while chat.isBusy && elapsed < timeoutNanoseconds {
        try? await Task.sleep(nanoseconds: step)
        elapsed += step
    }
}

@MainActor
@Test func chatManagerSharedIsSingleton() {
    let first = ChatManager.shared
    let second = ChatManager.shared

    #expect(ObjectIdentifier(first) == ObjectIdentifier(second))
}

@MainActor
@Test func modelLoaderAllModelsHasStableEntries() {
    #expect(!ModelLoader.allModels.isEmpty)

    let ids = ModelLoader.allModels.map(\.id)
    let uniqueIds = Set(ids)
    #expect(ids.count == uniqueIds.count)
}

@MainActor
@Test func modelLoaderNameUsesLastPathComponent() {
    let config = LLMRegistry.qwen3_0_6b_4bit
    let loader = ModelLoader(model: config)

    let expected = config.name.split(separator: "/").last.map(String.init) ?? config.name
    #expect(loader.name == expected)
}

@MainActor
@Test func modelLoaderEqualityAndHashUseId() {
    let config = LLMRegistry.gemma3_1B_qat_4bit
    let lhs = ModelLoader(model: config)
    let rhs = ModelLoader(model: config)

    #expect(lhs == rhs)
    #expect(lhs.hashValue == rhs.hashValue)
}

@MainActor
@Test func modelLoaderStateLoadingEqualityIgnoresTaskIdentity() {
    let firstTask = Task<ModelContainer, Error> {
        throw StubError.failed
    }
    let secondTask = Task<ModelContainer, Error> {
        throw StubError.failed
    }

    let firstState = ModelLoader.State.loading(firstTask)
    let secondState = ModelLoader.State.loading(secondTask)

    #expect(firstState == secondState)
}

@MainActor
@Test func chatGenerateAnswerStreamsChunks() async {
    let chat = LocalChatLib.Chat(modelName: "test") { _ in
        makeStream(chunks: ["Hel", "lo"])
    }

    chat.generateAnswer(from: "Hi")
    await waitUntilNotBusy(chat)

    #expect(chat.messages.count == 2)
    #expect(chat.messages[0].role == .user)
    #expect(chat.messages[0].content == "Hi")
    #expect(chat.messages[1].role == .assistant)
    #expect(chat.messages[1].content == "Hello")
    #expect(chat.lastErrorDescription == nil)
}

@MainActor
@Test func chatGenerateAnswerStoresErrorDescription() async {
    let chat = LocalChatLib.Chat(modelName: "test") { _ in
        makeStream(chunks: ["partial"], failure: StubError.failed)
    }

    chat.generateAnswer(from: "Hi")
    await waitUntilNotBusy(chat)

    #expect(chat.messages.count == 2)
    #expect(chat.messages[1].content == "partial")
    #expect(chat.lastErrorDescription != nil)
}

@MainActor
@Test func chatCancelStopsActiveTask() async {
    let chat = LocalChatLib.Chat(modelName: "test") { _ in
        makeStream(chunks: ["A", "B", "C"], delayNanoseconds: 200_000_000)
    }

    chat.generateAnswer(from: "Hi")
    chat.cancel()
    await waitUntilNotBusy(chat)

    #expect(!chat.isBusy)
    #expect(chat.lastErrorDescription == nil)
}

@MainActor
@Test func modelLoaderNewChatAppendsToChatManager() async throws {
    ChatManager.shared.chats.removeAll()

    let config = LLMRegistry.qwen3_0_6b_4bit
    let loader = ModelLoader(
        model: config,
        containerLoader: { _, _ in
            throw StubError.failed
        },
        chatFactory: { _, modelName in
            LocalChatLib.Chat(modelName: modelName) { _ in
                makeStream(chunks: [])
            }
        }
    )

    let chat = try await loader.newChat()

    #expect(ChatManager.shared.chats.count == 1)
    #expect(ChatManager.shared.chats.first?.id == chat.id)
}

@MainActor
@Test func modelLoaderLoadInBackgroundStoresError() async {
    let config = LLMRegistry.qwen3_0_6b_4bit
    let loader = ModelLoader(model: config) { _, _ in
        throw StubError.failed
    }

    loader.loadInBackground()

    for _ in 0..<100 {
        if loader.lastErrorDescription != nil {
            break
        }
        try? await Task.sleep(nanoseconds: 10_000_000)
    }

    #expect(loader.lastErrorDescription != nil)
}

@MainActor
@Test func modelLoaderLoadThrowsAndClearsLastErrorDescription() async {
    let config = LLMRegistry.llama3_2_1B_4bit
    let loader = ModelLoader(model: config) { _, _ in
        throw StubError.failed
    }

    loader.lastErrorDescription = "old error"

    var didThrow = false
    do {
        try await loader.load()
    } catch {
        didThrow = true
    }

    #expect(didThrow)
    #expect(loader.lastErrorDescription == nil)
}
