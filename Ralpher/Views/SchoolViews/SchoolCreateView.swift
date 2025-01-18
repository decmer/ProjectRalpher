//
//  SchoolCreateView.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 17/12/24.
//

import SwiftUI
import PhotosUI

struct SchoolCreateView: View {
    @Environment(ViewModel.self) private var vm
    
    @State private var name: String = ""
    @State private var img: Data?
    @State private var color: Color = .white
    @State private var isFileImporterPresented = false
    @State private var selectedItem: PhotosPickerItem? = nil

    @Binding var isPresented: Bool
    
    var body: some View {
        Form {
            HStack {
                Spacer()
                Text("Create New School")
                    .font(.title2)
                    .bold()
                Spacer()
            }
            Section {
                TextField("Name", text: $name)
                    .padding()
                ColorPicker("Color", selection: $color)
                    .padding()
            }
            
            Section {
                if let img, let uiImage = UIImage(data: img) {
                    HStack {
                        Spacer()
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .overlay {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            withAnimation {
                                                self.img = nil
                                                selectedItem = nil
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle")
                                                .foregroundStyle(.red)
                                                .frame(width: 35, height: 35)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        Spacer()
                    }
                } else {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            Text("Selecciona una foto")
                        }
                        .onChange(of: selectedItem) { newItem, _ in
                            Task {
                                if let selectedItem, let data = try? await selectedItem.loadTransferable(type: Data.self) {
                                    withAnimation {
                                        img = data
                                    }
                                }
                            }
                        }
                        .padding()
                }
            }
            
            Button("Create") {
                Task {
                    do {
                        try await vm.createSchool(SchoolsModel(name: name, color: color.toHex()))
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                isPresented = false
            }
        }
    }
}

#Preview {
    SchoolCreateView(isPresented: .constant(true))
        .environment(Preview.vm)
}
