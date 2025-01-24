//
//  JoinSchoolView.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 18/12/24.
//

import SwiftUI

struct JoinSchoolView: View {
    @Environment(ViewModel.self) private var vm

    @State var codeJoinSchool: String = ""
    
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Spacer()
            HStack {
                TextField("Code to join", text: $codeJoinSchool)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.gray.opacity(0.12))
                    }
                Button("Join") {
                    Task {
                        do {
                            try await vm.addUserToSchool(codeJoinSchool)
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
            .padding()
            Spacer()
        }
    }
}

#Preview {
    JoinSchoolView(isPresented: .constant(true))
        .environment(Preview.vm())
}
