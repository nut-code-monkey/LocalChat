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
                ProgressView(value: loader.progress) {
                    Text(loader.name)
                } currentValueLabel: {
                    Text(loader.progress, format: .percent)
                }
                .progressViewStyle(.linear)
                .onTapGesture {
                    print("Load \(loader.name)")
                    loader.load()
                }

                Button("New chat") {}
            }

            .padding(.vertical, 5)
        }
    }
}


#Preview {
    LocalModelsView()
}
