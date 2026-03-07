//
//  ModelLoadingView.swift
//  LocalChat
//
//  Created by Максим Лунін on 07.03.2026.
//

import SwiftUI

struct ModelLoadingView: View {
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
    ModelLoadingView(name: "Test/Model", progress: .constant(0))

    ModelLoadingView(name: "Test/Model", progress: .constant(0.5))

    ModelLoadingView(name: "Test/Model", progress: .constant(1))
}
