//
//  SettingsView.swift
//  Ralpher
//
//  Created by Jose Decena on 21/1/25.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct SettingsView: View {
    @Environment(ViewModel.self) var vm
    
    @State var selectedItem: PhotosPickerItem?
    @State var showAlert = false
    
    var body: some View {
        NavigationStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                preferredItemEncoding: .compatible,
                photoLibrary: .shared()) {
                    photoPreview
                }
                .onChange(of: selectedItem) { newItem, _ in
                    Task {
                        if let selectedItem, let data = try? await selectedItem.loadTransferable(type: Data.self) {
                            do {
                                try await vm.uploadImage(data, name: "")
                            } catch {
                                vm.messageError = error.localizedDescription
                            }
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Force Logout"),
                        message: Text("Do you want to force the logout?"),
                        primaryButton: .destructive(Text("Yes")) {
                            Task {
                                do {
                                    try await vm.forceLogout()
                                } catch {
                                    vm.messageError = error.localizedDescription
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Logout") {
                            Task {
                                do {
                                    try await vm.logoutUser()
                                } catch {
                                    showAlert = true
                                    vm.messageError = error.localizedDescription
                                }
                            }
                        }
                    }
                }
            
            Text(vm.users?.name ?? "none")
                .padding(.bottom, 10)
            Spacer()
        }
    }
    
    var photoPreview: some View {
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

#Preview {
    SettingsView()
        .environment(Preview.vm())
}
