//
//  ClassCourseView.swift
//  Ralpher
//
//  Created by Jose Merino Decena on 19/3/25.
//

import SwiftUI

struct ClassCourseView: View {
    @Environment(ViewModel.self) private var vm
    
    var classModels: [ClassModel] {
        if let classToCourse = vm.classToCourse {
            return classToCourse
        } else {
            return []
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(classModels) { clas in
                    classPreview(clas)
                        .swipeActions(edge: .trailing) {
                            Button(action: {
                                Task {
                                    do {
                                        try await vm.classDelCourse(idClass: clas.id!)
                                    } catch {
                                        vm.messageError = error.localizedDescription
                                    }
                                }
                            }) {
                                Label("Eliminar", systemImage: "trash.fill") // Icono de papelera
                            }
                            .tint(.red)
                        }
                }
            }
            .background(Color.clear)
            .listStyle(InsetListStyle())
        }
    }
    
    func classPreview(_ clas: ClassModel) -> some View {
        Text(clas.name)
    }
}


#Preview {
    ClassCourseView()
        .environment(Preview.vm())
}
