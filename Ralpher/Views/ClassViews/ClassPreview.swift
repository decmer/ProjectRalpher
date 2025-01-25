//
//  ClassPreview.swift
//  Ralpher
//
//  Created by Jose Decena on 18/1/25.
//

import SwiftUI

struct ClassPreview: View {
    let classModel: ClassModel
    
    var body: some View {
        RoundedRectangle(cornerRadius: 7)
            .foregroundStyle(Color(hex: classModel.color ?? Color.black.toHex()!))
            .overlay {
                VStack {
                    HStack {
                        Text(classModel.name)
                            .foregroundStyle(.white)
                            .padding(7)
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
                    RoundedRectangle(cornerRadius: 7)
                        .frame(height: 1)
                        .foregroundStyle(.white)
                    Spacer()
                    RoundedRectangle(cornerRadius: 7)
                        .foregroundStyle(Color.white)
                        .overlay {
                            VStack {
                                Text("Tareas pendientes")
                                    .underline()
                                    .font(.footnote)
                                    .foregroundStyle(.black)
                                    .padding(7)
                                Spacer()
                                
                            }
                        }
                        .padding(3)
                }
            }
    }
    func removeItem() {
    }
}

#Preview {
    ClassPreview(classModel: .init(name: "jose", id_school: 244, specified_for_course: false))
        .frame(width: 250, height: 250)
}
