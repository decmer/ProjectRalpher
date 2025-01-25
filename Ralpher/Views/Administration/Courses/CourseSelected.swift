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
                        ReleaseView()
                            .padding()
                    }
                    
                    Spacer()
                }
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
