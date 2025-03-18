//
//  LoadScreenView.swift
//  Ralpher
//
//  Created by Jose Merino Decena on 18/3/25.
//

import SwiftUI

struct LoadScreenView: View {
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            ProgressView("Cargando...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding(50)
                .foregroundColor(.blue)
        }
        .modifier(FloatingMessageModifier())
    }
}
