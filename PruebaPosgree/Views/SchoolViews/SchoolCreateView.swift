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
        VStack {

                TextField("Name", text: $name)
                .padding()

            

                ColorPicker("Color", selection: $color)
                .padding()

            


                PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()) {
                                Text("Selecciona una foto")
                            }
                            .onChange(of: selectedItem) { newItem, _ in
                                Task {
                                    if let selectedItem, let data = try? await selectedItem.loadTransferable(type: Data.self) {
                                        img = data
                                    }
                                }
                            }
                            .padding()
                        if let img, let uiImage = UIImage(data: img) {
                            HStack {
                                Spacer()
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                Spacer()
                            }
                        }
                

            Spacer()
            Button("Create") {
                Task {
                    do {
                        try await vm.createSchool(SchoolsModel(name: name, color: color.toHex()))
                        print("creado")
                        isPresented = false
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
        }
        
    }
}

#Preview {
    SchoolCreateView(isPresented: .constant(true))
        .environment(Preview.vm)
}
