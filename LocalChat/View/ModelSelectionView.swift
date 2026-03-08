//
//  LocalModelsView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI
import LocalChatLib

struct ModelSelectionView: View {
    @Environment(\.navigation) private var navigation
    @Environment(\.dismiss) private var dismiss

    enum Mode {
        case full
        case compact
    }
    var view: Mode

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select model for new chat:")
            ForEach(ModelLoader.allModels) { loader in
                switch view {
                case .full:
                    loaderView(for: loader)
                        .onTapGesture { select(loader) }

                case .compact:
                    Button(loader.name) { select(loader) }
                }
            }
            Spacer()
        }
        .padding()
    }

    private func select(_ loader: ModelLoader) {
        loader.load()
        navigation.push(loader: loader)
        dismiss()
    }

    private func loaderView(for loader: ModelLoader) -> some View {
        ZStack {
            ProgressView(value: loader.progress) { Text(loader.name) }
            currentValueLabel: { Text(loader.progress, format: .percent) }
                .progressViewStyle(.linear)
                .padding(12)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview("Compact view") {
    @Previewable @State var navigation = Navigation()
    NavigationStack(path: $navigation.path) {
        ModelSelectionView(view: .compact)
    }
    .environment(\.navigation, navigation)
}

#Preview("Full view") {
    @Previewable @State var navigation = Navigation()
    NavigationStack(path: $navigation.path) {
        ModelSelectionView(view: .full)
    }
    .environment(\.navigation, navigation)
}

