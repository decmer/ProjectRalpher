//
//  CourseAddView.swift
//  Ralpher
//
//  Created by Jose Decena on 25/1/25.
//

import SwiftUI

struct CourseAddView: View {
    @Environment(ViewModel.self) private var vm

    @State var name: String = ""
    
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Spacer()
            Text("Create a new course")
                .font(.title)
            HStack {
                TextField("Name", text: $name)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.gray.opacity(0.12))
                    }
                Button("Create") {
                    Task {
                        do {
                            try await vm.createCourse(name)
                        } catch {
                            vm.messageError = error.localizedDescription
                        }
                    }
                    isPresented = false
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .padding()
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}

#Preview {
    @Previewable @State var bool = true
    CourseAddView(isPresented: $bool)
        .environment(Preview.vm())
}
