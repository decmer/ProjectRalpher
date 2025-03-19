//
//  InformationView.swift
//  Ralpher
//
//  Created by Jose Decena on 20/1/25.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct InformationView: View {
    @Environment(ViewModel.self) private var vm

    @State var code: String?
    @State var codeVisibility: Bool = false
    @State var newNameSchool: String = ""
    @State var newColorSchool: Color = .black
    @State var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage? = nil

    
    var body: some View {
        if vm.schoolSelected != nil {
            NavigationStack {
                VStack {
                    Spacer()
                    HStack {
                        Text("Code")
                        Spacer()
                        if code != nil, codeVisibility {
                            CopyableTextView(code!)
                                .frame(width: 150)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 150, height: 20)
                        }
                        Button {
                            if codeVisibility {
                                withAnimation {
                                    code = nil
                                    codeVisibility = false
                                }
                            } else {
                                Task {
                                    withAnimation {
                                        codeVisibility = false
                                    }
                                    do {
                                        code = try await vm.fetchSchoolsKey()
                                    } catch {
                                        vm.messageError = error.localizedDescription
                                    }
                                    withAnimation {
                                        codeVisibility = true
                                    }
                                }
                            }
                        } label: {
                            if codeVisibility {
                                Image(systemName: "eye.circle.fill")
                                    .foregroundStyle(.blue)
                                    .frame(width: 20, height: 20)
                            } else {
                                Image(systemName: "eye.slash.circle.fill")
                                    .foregroundStyle(.blue)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        
                    }
                    .padding(.horizontal, 30)
                    
                    HStack {
                        Text("Name School")
                        TextField(vm.schoolSelected?.name ?? "None", text: $newNameSchool)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding([.horizontal, .top], 30)
                    
                    ColorPicker("Pick a color", selection: $newColorSchool)
                    .onAppear {
                        newColorSchool = Color(hex: (vm.schoolSelected?.color)!)
                    }
                    .padding(vm.schoolSelected?.imgurl == nil ? 0 : 30)
                    
                    if let img = vm.schoolSelected?.imgurl {
                        Section(content: {
                            HStack {
                                Text("Image")
                                Spacer()
                            }
                            .padding(.horizontal, 30)
                                
                        }, footer: {
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images,
                                preferredItemEncoding: .compatible,
                                photoLibrary: .shared()) {
                                    photoPreview(img)
                                }
                                .onChange(of: selectedItem) { old, newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                                           let image = UIImage(data: data) {
                                            selectedImage = image
                                        }
                                    }
                                }
                        })
                    }
                    
                    Spacer()
                    
                    Button {
                        if !newNameSchool.isEmpty {
                            vm.schoolSelected?.name = newNameSchool
                        }
                        vm.schoolSelected?.color = newColorSchool.toHex()
//                        vm.schoolSelected?.image = vm.
                        Task {
                            do {
                                try await vm.updateSchool()
                            } catch {
                                vm.messageError = error.localizedDescription
                            }
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .frame(width: 120, height: 40)
                                .foregroundStyle(.blue)
                            Text("Save")
                                .foregroundStyle(.white)
                        }
                    }
                    .padding()
                }
            }
        } else {
            Text("Error")
        }
    }
    
    func photoPreview(_ img: String) -> some View {
        Group {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .frame(width: 350, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                AsyncImage(url: URL(string: img)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 350, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    InformationView()
        .environment(Preview.vm())
}
