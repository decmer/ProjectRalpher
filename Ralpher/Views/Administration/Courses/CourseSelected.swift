//
//  CourseSelected.swift
//  Ralpher
//
//  Created by Jose Decena on 25/1/25.
//

import SwiftUI

struct CourseSelected: View {
    @Environment(ViewModel.self) private var vm
    
    @State var option: OptionView = .usersO
    @State var showAddUser = false
    
    let name: String
    
    var body: some View {
        NavigationStack {
            if let course = vm.courseSelected {
                VStack {
                    Picker("Role", selection: $option) {
                        ForEach(OptionView.allCases, id: \.self) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                    
                    .pickerStyle(SegmentedPickerStyle())
                    .navigationTitle(course.0.name)
                    
                    switch option {
                    case .usersO:
                        UsersView()
                    case .classO:
                        ClassCourseView()
                            .padding()
                    }
                    
                    Spacer()
                }
                .sheet(isPresented: $showAddUser) {
                    switch option {
                    case .usersO:
                        AddUsersCourseView{ users in
                            Task {
                                do {
                                    try await vm.usersAddCourse(idUser: users)
                                    let userToScullAux = try await vm.fetchCourseUsersSchool(vm.courseSelected!.0.id!)
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            vm.userToCourse = userToScullAux
                                        }
                                    }
                                    showAddUser = false
                                } catch {
                                    vm.messageError = error.localizedDescription
                                }
                            }
                        }
                    case .classO:
                        addClassCourseView { listId in
                            Task {
                                do {
                                    try await vm.classAddCourse(idClass: listId)
                                    showAddUser = false
                                } catch {
                                    vm.messageError = error.localizedDescription
                                }
                            }
                        }
                    }
                    
                }
                .toolbar(content: {
                    Button {
                        showAddUser = true
                    } label: {
                        Text("add")
                    }
                })
            } else {
                ProgressView()
                    .navigationTitle(name)
            }
        }
    }
    
    enum OptionView: String, CaseIterable, Hashable {
        case usersO = "Users"
        case classO = "Class"
    }
}

#Preview {
    CourseSelected(name: "Hola")
        .environment(Preview.vm())
}
