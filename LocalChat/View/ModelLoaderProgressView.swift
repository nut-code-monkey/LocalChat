//
//  ModelLoaderProgressView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI

struct ModelLoaderProgressView: View {
    @State var name: String
    @Binding var progress: Double
    var body: some View {
        ProgressView(value: progress) {
            Text("Loading \(name)...")
        } currentValueLabel: {
            Text(progress, format: .percent)
        }
        .progressViewStyle(.linear)
        .padding()
    }
}

#Preview {
    ModelLoaderProgressView(
        name: "Test/Model",
        progress: .constant(0)
    )

    ModelLoaderProgressView(
        name: "Test/Model",
        progress: .constant(0.5)
    )

    ModelLoaderProgressView(
        name: "Test/Model",
        progress: .constant(1)
    )
}
