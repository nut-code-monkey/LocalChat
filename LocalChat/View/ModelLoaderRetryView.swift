//
//  ModelLoaderRetryView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI

struct ModelLoaderRetryView: View {
    @State var errorMessage: String
    var action: () async -> Void
    var body: some View {
        ContentUnavailableView{
            Text("Model loading error:")
        } description: {
            Text(errorMessage)
        } actions: {
            Button("Retry") { Task{ await action() } }
        }
    }
}

#Preview {
    ModelLoaderRetryView(errorMessage: "test message") {
        print("retry clicked")
    }
}
