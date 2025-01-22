//
//  CopyableTextView.swift
//  Ralpher
//
//  Created by Jose Decena on 22/1/25.
//

import SwiftUI

struct CopyableTextView: View {
    let text: String
    @State private var isCopied = false

    init(_ text: String, isCopied: Bool = false) {
        self.text = text
        self.isCopied = isCopied
    }
    
    var body: some View {
        VStack {
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .onTapGesture {
                    UIPasteboard.general.string = text
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                        isCopied = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isCopied = false
                        }
                    }
                }

            if isCopied {
                Text("¡Copiado!")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(
                        Capsule()
                            .fill(Color.green)
                            .shadow(color: .green.opacity(0.5), radius: 4, x: 0, y: 2)
                    )
                    .scaleEffect(isCopied ? 1.1 : 1.0)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(8)
    }
}

#Preview {
    CopyableTextView("dffg")
        .frame(width: 150, height: 40)
}
