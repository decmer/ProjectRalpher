//
//  ProfileEditView.swift
//  Ralpher
//
//  Created by Jose Merino Decena on 16/3/25.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct ProfileEditView: View {
    @Environment(ViewModel.self) var vm
    
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var imageUrl: String = ""
    @State var selectedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.form.opacity(1)
                    .ignoresSafeArea()
                VStack {
                    Section(header: Text("Profile Photo").opacity(0.7)) {
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            preferredItemEncoding: .compatible,
                            photoLibrary: .shared()) {
                                photoPreview
                            }
                    }
                    
                    Form {
                        Section(header: Text("Información Personal")) {
                            TextField("Nombre", text: $name)
                            TextField("Apellido", text: $surname)
                        }
                        
                        
                        
                        Section {
                            Button("Guardar") {
                                saveProfile()
                            }
                            .disabled(name.isEmpty || surname.isEmpty)
                        }
                    }
                    .scrollContentBackground(.hidden) // Oculta el fondo predeterminado del Form
                    .background(Color.clear) // Hace que el fondo sea transparente
                    
                    
                }
                .padding(.top, 20)
                .navigationTitle("Create Profile")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Logout") {
                            Task {
                                do {
                                    try await vm.logoutUser()
                                } catch {
                                    vm.messageError = error.localizedDescription
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    var photoPreview: some View {
        VStack {
            AsyncImage(url: URL(string: vm.users?.imgurl ?? "https://xvkymhtcipdbdanikzpq.supabase.co/storage/v1/object/public/img/userProfileBasic.png?t=2025-01-21T18%3A49%3A17.726Z")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 150, height: 150)
            .clipShape(Circle())
        }
    }
    
    private func saveProfile() {
        Task {
            if let selectedItem, let data = try? await selectedItem.loadTransferable(type: Data.self) {
                do {
                    try await vm.uploadImage(data, name: "")
                } catch {
                    vm.messageError = error.localizedDescription
                }
            }
        }
        vm.users?.name = name
        vm.users?.surname = surname
        vm.isLoading = true
    }
}


#Preview {
    ProfileEditView()
        .environment(Preview.vm())
}
