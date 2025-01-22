//
//  UserAuthenticationView.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 11/12/24.
//

import SwiftUI
import _AuthenticationServices_SwiftUI

struct UserAuthenticationView: View {
    @Environment(ViewModel.self) var vm
    @State var isLoginPresented: Bool = true
    @State var message: String?

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                ZStack {
                    if isLoginPresented {
                        LoginView(isPresented: $isLoginPresented, showAlertMesage: $message)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    } else {
                        SignupView(isPresented: $isLoginPresented)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5), value: isLoginPresented)
                
                Spacer()
                
                Divider()
                
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.email, .fullName]
                    },
                    onCompletion: { result in
                        Task {
                            do {
                                try await vm.authenticateWithApple(result)
                            } catch {
                                message = error.localizedDescription
                                
                            }
                        }
                    }
                )
                .frame(width: 300, height: 50)
                .padding()
                
                Button(action: {
                    Task {
                        do {
                            try await vm.googleSignIn()
                        } catch {
                            message = error.localizedDescription
                            print(message!)
                        }
                    }
                }) {
                    HStack {
                        Image("google")
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text("Iniciar sesión con Google")
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding()
                    }
                    .frame(width: 300, height: 50)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(6)
                    .padding(.horizontal, 40)
                }
            }
            .navigationTitle(isLoginPresented ? "Login" : "Sign Up")
        }
        .modifier(FloatingMessageModifier(message: $message))
    }
}

#Preview {
    UserAuthenticationView()
        .environment(Preview.vm())
}
