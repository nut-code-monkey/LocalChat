//
//  LocalModelsView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI
import LocalChatLib

struct LocalModelsView: View {
    var body: some View {
        List(ModelLoader.allModels) { loader in
            HStack {
                Text(loader.name)

                Spacer()
                if loader.isLoaded {
                    Image(systemName: "checkmark.square")
                } else {
                    Image(systemName: "square.and.arrow.down")
                }
            }

            if loader.isLoaded {
                ProgressView("Loading...",
                             value: loader.progress,
                             total: 1)
                .progressViewStyle(.linear)
            }
        }
    }
}


#Preview {
    LocalModelsView()
}
