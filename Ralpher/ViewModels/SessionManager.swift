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
import _PhotosUI_SwiftUI

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
        
        let session = try await supabase.auth.signInWithIdToken(
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
        self.users = try await fetchUser(id: session.user.id)
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

        let session = try await supabase.auth.signInWithIdToken(
          credentials: OpenIDConnectCredentials(
            provider: .google,
            idToken: idToken,
            accessToken: accessToken
          )
        )
        self.users = try await fetchUser(id: session.user.id)
        isAuthenticated = true
    }
    
    func loginUser(email: String, password: String) async throws {
        let session = try await supabase.auth.signIn(email: email, password: password)
        isAuthenticated = true
        print("Sesión iniciada. Token de acceso:", session.accessToken)
        print("Id: ", session.user.id)
        self.users = try await fetchUser(id: session.user.id)
    }
    
    func logoutUser() async throws {
        try await supabase.auth.signOut()
        self.users = nil
        self.schools = []
        self.isAuthenticated = nil
        self.channelUser = nil
        self.cacheSchools = []
        self.cacheCourse = []
    }

    
    func isSessionValid() async throws -> Bool {
        guard let expiresAt = try await supabase.auth.session.expiresAt else {
            return false
        }
        // Comparar la fecha actual (en segundos desde la época Unix) con la fecha de expiración
        return Date().timeIntervalSince1970 < expiresAt
    }
    func forceLogout() async throws {
        try await supabase.auth.signOut()

        clearUserDefaults()

        self.users = nil
        self.schools = []
        self.isAuthenticated = nil
        self.channelUser = nil
        self.cacheSchools = []
        self.cacheCourse = []

        // Refresca la sesión para asegurarse de que se elimina todo
        try await refreshSession()
    }

    func clearUserDefaults() {
        // Elimina cualquier rastro de la sesión en UserDefaults
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.synchronize()
    }

    func refreshSession() async throws {
        try await supabase.auth.refreshSession()
    }
    
    func resetPassword(email: String) async {
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            print("Correo de recuperación enviado.")
        } catch {
            messageError = error.localizedDescription
        }
    }
    
    func resendVerificationEmail(email: String) async throws {
        try await supabase.auth.resend(email: email, type: .signup)
    }
    
    func restoreSession() async throws {
        let user = try await supabase.auth.session.user
        self.users = try await fetchUser(id: user.id)
        isAuthenticated = true
    }
    
    func getIdUser() async throws -> UUID? {
        var id: UUID?
        do {
            id = try await supabase.auth.session.user.id
        } catch {
            messageError = error.localizedDescription
        }
        return id
    }
    
    func saveProfile(selectedItem: PhotosPickerItem?, name: String, surname: String) {
        Task {
            do {
                if let id = try await getIdUser() {
                    var user = UserModel(id: id, name: name, surname: surname)
                    
                    if let selectedItem, let data = try? await selectedItem.loadTransferable(type: Data.self) {
                        let fileName = UUID().uuidString
                        
                        try await supabase.storage.from("img")
                            .upload(
                                path: fileName,
                                file: data,
                                options: FileOptions(contentType: "image/jpeg")
                            )
                        if let oldFileName = self.users?.imgname {
                            try await removeItemBucket(oldFileName, bucketName: "img")
                        }
                        user.imgname = fileName
                        user.imgurl = try await getURLBucket(fileName).absoluteString
                    } else {
                        messageError = "No se ha podido seleccionar una imagen"
                    }
                    try await supabase.database.from("users").insert(user).execute()
                    self.users = user
                } else {
                    messageError = "No se ha podido obtener el ID del usuario"
                }
            } catch {
                messageError = error.localizedDescription
            }
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
