//
//  SessionManager.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 11/12/24.
//

import SwiftUI
import Supabase
import AuthenticationServices
import GoogleSignIn

extension ViewModel {
    
    func registerUser(email: String, password: String) async {
        do {
            let response = try await supabase.auth.signUp(email: email, password: password)
            print("Usuario creado con éxito:", response.user.id)
        } catch {
            print("Error al registrar usuario:", error.localizedDescription)
        }
    }
    
    func authenticateWithApple(_ result: Result<ASAuthorization, any Error>) async throws {
        guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential else {
            return
        }

        guard let idToken = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8)}) else {
            return
        }
        
        try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken
            )
        )
        
        Task {
            do {
                self.schools = try await supabase.database.from("schools").select().execute().value
            } catch {
                print("Error al obtener las escuelas:", error.localizedDescription)
            }
        }
        
        isAuthenticated = true
    }
    
    @MainActor
    func getRootViewController() -> UIViewController {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            fatalError("No se pudo obtener el controlador de vista raíz.")
        }
        return rootViewController
    }
    
    func googleSignIn() async throws {
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController())
        
        guard let idToken = result.user.idToken?.tokenString else {
          print("No idToken found.")
          return
        }

        let accessToken = result.user.accessToken.tokenString

        try await supabase.auth.signInWithIdToken(
          credentials: OpenIDConnectCredentials(
            provider: .google,
            idToken: idToken,
            accessToken: accessToken
          )
        )
        isAuthenticated = true
    }
    
    func loginUser(email: String, password: String, mesageError: Binding<String?>) async {
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            isAuthenticated = true
            print("Sesión iniciada. Token de acceso:", session.accessToken)
            print("Id: ", session.user.id)
        } catch {
            mesageError.wrappedValue = error.localizedDescription
            print("Error al iniciar sesión:", error.localizedDescription)
        }
    }
    
    func logoutUser() async {
        do {
            try await supabase.auth.signOut()
            isAuthenticated = false
            print("Sesión cerrada.")
        } catch {
            print("Error al cerrar sesión:", error.localizedDescription)
        }
    }
    
    func resetPassword(email: String) async {
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            print("Correo de recuperación enviado.")
        } catch {
            print("Error al enviar correo de recuperación:", error.localizedDescription)
        }
    }
    
    func resendVerificationEmail(email: String) async throws {
        try await supabase.auth.resend(email: email, type: .signup)
    }
    
    func restoreSession() async {
        do {
            let user = try await supabase.auth.session.user
            print("Sesión restaurada. Usuario:", user.id)
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
    }
}

class GoogleSignInViewController: UIViewController {

  func googleSignIn() async throws {
    let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: self)

    guard let idToken = result.user.idToken?.tokenString else {
      print("No idToken found.")
      return
    }

    let accessToken = result.user.accessToken.tokenString

    try await supabase.auth.signInWithIdToken(
      credentials: OpenIDConnectCredentials(
        provider: .google,
        idToken: idToken,
        accessToken: accessToken
      )
    )
  }

}
