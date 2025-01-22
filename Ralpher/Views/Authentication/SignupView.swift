//
//  SignupView.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 11/12/24.
//

import SwiftUI

struct SignupView: View {
    @Environment(ViewModel.self) var vm
    
    @Binding var isPresented: Bool
    
    @State var pasword = ""
    @State var mail = ""
    @State var confirmPassword = ""
    @State var isValidate: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            SignupInput(mail: $mail, password: $pasword, confirmPassword: $confirmPassword)
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    await vm.registerUser(email: mail, password: pasword)
                }
            }) {
                Text("Sign Up")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValidate ? Color.blue : Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(!isValidate)
            .animation(.easeInOut, value: isValidate)

            Spacer()
            
            HStack {
                Text("Already have an account?")
                Button(action: {
                    withAnimation {
                        isPresented.toggle()
                    }
                }) {
                    Text("Login")
                        .bold()
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 40)
        }
        .onChange(of: mail) { _, _ in validateFields() }
        .onChange(of: pasword) { _, _ in validateFields() }
        .onChange(of: confirmPassword) { _, _ in validateFields() }
    }
    
    private func validateFields() {
        isValidate = !mail.isEmpty && !pasword.isEmpty && pasword == confirmPassword
    }
}


#Preview {
    SignupView(isPresented: .constant(false))
        .environment(Preview.vm())
}
