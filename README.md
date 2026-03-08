# LocalChat

LocalChat is a lightweight SwiftUI app that demonstrates a simple local-first chat experience. It lists active chats, lets you create a new chat, and navigates into individual conversations. The project is split into an app target and a supporting `LocalChatLib` module for core chat functionality.

## How it works

- SwiftUI: App provide minimum functionality - shows a list of available local models, active chats and exposes a "New chat" button.
- Navigation: A custom `Navigation` environment value and a `NavigationStack` manage navigation.
- For chat UI Used [SpeziChat](https://swiftpackageindex.com/StanfordSpezi/SpeziChat/) package.
- LocalChatLib: Responsible for interaction with local LLM via [Apple MLX framwork](https://opensource.apple.com/projects/mlx/) 

## Getting started

1. Open the project in Xcode 15+.
2. Build and run the `LocalChat` scheme.
3. From the main screen:
   - Tap "New chat" to create a new conversation.
   - Tap any listed chat to navigate to its detail screen.

## Project structure

- `LocalChat` (app target): SwiftUI views, navigation, and app lifecycle.
- `LocalChatLib` (library target): Chat models, loading, and supporting logic.

## TODO

- Add chat management: remove, rename.
- Add chat name according to first user message or conversation.
- Add persistence to save, recreate and cache chats.
- Add images / video support.

## License

This project is provided as-is for demonstration purposes. Add your preferred license here.
