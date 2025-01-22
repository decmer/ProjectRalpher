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
                    if let image = model.image {
//                        Image(uiImage: )
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(maxHeight: 155)
//                            .clipShape(RoundedRectangle(cornerRadius: 7))
//                            .overlay {
//                                VStack {
//                                    HStack {
//                                        Spacer()
//                                        Menu {
//                                            Button(action: removeItem) {
//                                                Text("Delete")
//                                            }
//                                        } label: {
//                                            Image(systemName: "ellipsis")
//                                                .foregroundStyle(.black)
//                                                .background {
//                                                    Circle()
//                                                        .frame(width: 30, height: 30)
//                                                        .foregroundStyle(.white)
//                                                }
//                                                .padding(15)
//                                        }
//                                    }
//                                    Spacer()
//                                }
//                            }
                            
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
                print(error.localizedDescription)
            }
        }
        
    }
}

#Preview {
    SchoolPreview(model: SchoolsModel(name: "Instituto tecnologico pablo de la torre", color: "5c1b6c"))
        .environment(Preview.vm())
        .frame(width: 350, height: 200)
        .padding(.vertical, 12)
}
