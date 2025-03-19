//
//  addClassCourseView.swift
//  Ralpher
//
//  Created by Jose Merino Decena on 19/3/25.
//

import SwiftUI

struct addClassCourseView: View {
    @Environment(ViewModel.self) private var vm
    
    var classJoinCourse: [ClassModel]? {
        if let classM = vm.classM, let classCourse = vm.classToCourse {
            let setClassM = Set(classM)
            let setClassCourse = Set(classCourse)
            return Array(setClassM.symmetricDifference(setClassCourse))
        }
        return nil
    }
    var functionAdd: (Set<Int>) -> Void
    @State var addClassModel: Set<Int> = []
    
    var body: some View {
        NavigationStack {
            if let classJoinCourse = classJoinCourse {
                if classJoinCourse.isEmpty {
                    VStack {
                        Spacer()
                        Text("No class to add")
                            .font(.headline)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(classJoinCourse) { clasM in
                            classPreview(clasM)
                                .onTapGesture {
                                    if addClassModel.contains(clasM.id!) {
                                        addClassModel.remove(clasM.id!)
                                    } else {
                                        addClassModel.insert(clasM.id!)
                                    }
                                }
                        }
                    }
                    .background(Color.clear)
                    .listStyle(.automatic)
                    .toolbar {
                        Button {
                            functionAdd(addClassModel)
                        } label: {
                            Text("Add")
                        }
                        .disabled(addClassModel.isEmpty)
                    }
                }
            } else {
                Text("Error por favor salte de la aplicacion y vuelve a entrar")
            }
        }
    }
    
    func classPreview(_ clas: ClassModel) -> some View {
        ZStack {
            Color.clear
                        .contentShape(Rectangle())
            HStack {
                VStack(alignment: .leading) {
                    Text(clas.name)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(clas.description ?? "Unknown")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                ZStack {
                    Circle()
                        .strokeBorder(addClassModel.contains(clas.id!) ? Color.blue : Color.black.opacity(0.2), lineWidth: 2)
                        .frame(width: 30, height: 30)
                    
                    if addClassModel.contains(clas.id!) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .font(.system(size: 18))
                    }
                }
            }
        }
    }
}

#Preview {
    addClassCourseView(functionAdd: { _ in
        
    })
        .environment(Preview.vm())
}
