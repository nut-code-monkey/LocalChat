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

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select model for new chat:")
            ForEach(ModelLoader.allModels) { model in
                Button(model.name) { select(model) }
            }
            Spacer()
        }
        .padding()
    }

    private func select(_ model: ModelLoader) {
        navigation.newChat(with: model)
        dismiss()
    }
}

#Preview("Compact view") {
    @Previewable @State var navigation = Navigation()
    NavigationStack(path: $navigation.path) {
        ModelSelectionView()
    }
    .environment(\.navigation, navigation)
}

