//
//  ContentView.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 10/12/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(ViewModel.self) var vm
    
    @Binding var isPresented: Bool
    
    @State var pasword = ""
    @State var mail = ""
    @State var isValidate: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            LoginInput(mail: $mail, password: $pasword)
                .padding(.horizontal)
                .padding(.top, 40)
                .opacity(isValidate ? 1 : 0.8)
                .animation(.easeInOut, value: isValidate)

            HStack {
                Spacer()
                Button(action: {
                    Task {
                        await vm.resetPassword(email: mail)
                    }
                }) {
                    Text("Forgot Password?")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                .padding(.horizontal)
            }
            
            Button(action: {
                Task {
                    do {
                        try await vm.loginUser(email: mail, password: pasword)
                    } catch {
                        vm.messageError = "Error al iniciar sesión:" + error.localizedDescription
                    }
                }
            }) {
                Text("Login")
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
                Text("Don’t have an account?")
                Button(action: {
                    withAnimation {
                        isPresented.toggle()
                    }
                }) {
                    Text("Sign Up")
                        .bold()
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 40)
        }
        
        .onChange(of: mail) { _, _ in validateFields() }
        .onChange(of: pasword) { _, _ in validateFields() }
    }
    
    private func validateFields() {
        isValidate = !mail.isEmpty && !pasword.isEmpty
    }
}


#Preview {
    LoginView(isPresented: .constant(true))
        .environment(Preview.vm())
}

