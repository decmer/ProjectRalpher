//
//  SchoolPreview.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 17/12/24.
//

import SwiftUI

struct SchoolPreview: View {
    @Environment(ViewModel.self) private var vm
    
    var model: SchoolsModel
    
    var body: some View {
        RoundedRectangle(cornerRadius: 7)
            .foregroundStyle(Color(hex: model.color ?? ""))
            .overlay {
                VStack {
                    if let image = model.imgurl {
                        photoPreview(image)
                            .frame(maxHeight: 155)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                            .overlay {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Menu {
                                            Button(action: removeItem) {
                                                Text("Delete")
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .foregroundStyle(.black)
                                                .background {
                                                    Circle()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundStyle(.white)
                                                }
                                                .padding(15)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            
                    } else {
                        HStack {
                            Spacer()
                            Menu {
                                Button(action: removeItem) {
                                    Text("Delete")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundStyle(.black)
                                    .background {
                                        Circle()
                                            .frame(width: 30, height: 30)
                                            .foregroundStyle(.white)
                                    }
                                    .padding(15)
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text(model.name)
                            .foregroundStyle(Color(hex: model.color ?? "").contrastingColor())
                            .padding([.bottom, .horizontal], 15)
                        Spacer()
                    }
                }
            }
    }
    func removeItem() {
        Task {
            do {
                try await vm.dropOutOfSchool(model)
            } catch {
                vm.messageError = error.localizedDescription
            }
        }
        
    }
    
    func photoPreview(_ image: String) -> some View {
        AsyncImage(url: URL(string: image)) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ProgressView()
        }
        .frame(width: .infinity, height: 150)
    }
}

#Preview {
    SchoolPreview(model: SchoolsModel(name: "Instituto tecnologico pablo de la torre", color: "5c1b6c",imgname: "233C7FC7-C0AE-4558-A858-1B09A9C4BBE4", imgurl: "https://xvkymhtcipdbdanikzpq.supabase.co/storage/v1/object/public/img//233C7FC7-C0AE-4558-A858-1B09A9C4BBE4"))
        .environment(Preview.vm())
        .frame(width: 350, height: 200)
        .padding(.vertical, 12)
}
