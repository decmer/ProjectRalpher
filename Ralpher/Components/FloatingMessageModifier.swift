//
//  FloatingMessageModifier.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 12/12/24.
//

import SwiftUI

struct FloatingMessageModifier: ViewModifier {
    @Binding var message: String?
    @State private var isVisible: Bool = false

    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content

            if let message = message {
                Text(message)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .shadow(radius: 10)
                    .padding([.top, .trailing], 20)
                    .offset(x: isVisible ? 0 : UIScreen.main.bounds.width)
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width > 50 {
                                    withAnimation {
                                        self.isVisible = false
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        self.message = nil
                                    }
                                }
                            }
                    )
                    .onAppear {
                        withAnimation {
                            isVisible = true
                        }
                        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                if isVisible {
                                    withAnimation {
                                        isVisible = false
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        self.message = nil
                                    }
                                }
                            }
                        }
                    }
                    .onDisappear {
                        isVisible = false
                    }
            }
        }
    }
}

#Preview {
    NavigationStack {
        Text("hoolla")
    }
        .modifier(FloatingMessageModifier(message: .constant("Error en el inicio de secion")))
}
