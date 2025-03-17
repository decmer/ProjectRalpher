//
//  ClassView.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 14/12/24.
//

import SwiftUI

struct UsersView: View {
    @Environment(ViewModel.self) private var vm
    @EnvironmentObject var tabViewModel: TabViewModel

    var groupedUsers: [RoleSchool: [UserModel]] {
        guard let userToSchool = vm.userToSchool else { return [:] }
        guard let userToCourse = vm.userToCourse else {
            return Dictionary(grouping: userToSchool.map { $0.0 }, by: { pair in
                userToSchool.first(where: { $0.0.id == pair.id })?.1 ?? .student
            })
        }
        return Dictionary(grouping: userToSchool.map { $0.0 }.filter({ item in
            userToCourse.contains(where: { $0.id == item.id })
        }), by: { pair in
            userToSchool.first(where: { $0.0.id == pair.id })?.1 ?? .student
        })
    }
    
    var body: some View {
        NavigationStack {
            if vm.userToCourse != nil {
                List {
                    ForEach(RoleSchool.allCases, id: \.self) { role in
                        if let users = groupedUsers[role], !users.isEmpty {
                            Section(header: Text(role.rawValue.capitalized)) {
                                ForEach(users) { user in
                                    if user.id == vm.users?.id {
                                        userPreview(user: user, role: role)
                                            .onTapGesture {
                                                tabViewModel.selectedTab = 2
                                            }
                                    } else {
                                        userview(user: user, role: role)
                                            
                                    }
                                }
                                
                            }
                            
                        }
                    }
                }
                .background(Color.clear)
                .listStyle(InsetListStyle())
            } else {
                List {
                    ForEach(RoleSchool.allCases, id: \.self) { role in
                        if let users = groupedUsers[role], !users.isEmpty {
                            Section(header: Text(role.rawValue.capitalized)) {
                                ForEach(users) { user in
                                    if user.id == vm.users?.id {
                                        userPreview(user: user, role: role)
                                            .onTapGesture {
                                                tabViewModel.selectedTab = 2
                                            }
                                    } else {
                                        userview(user: user, role: role)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Users by Role")
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
    
    func userview(user: UserModel, role: RoleSchool) -> some View {
        NavigationLink {
            UserView(user: user, role: role)
        } label: {
            userPreview(user: user, role: role)
        }
        .swipeActions(edge: .trailing) {
            Button(action: {
                Task {
                    do {
                        try await vm.userDelCourse((vm.courseSelected?.0.id)!, idUser: user.id)
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
    
    func userPreview(user: UserModel, role: RoleSchool) -> some View {
        HStack {
            AsyncImage(url: URL(string: user.imgurl ?? "https://xvkymhtcipdbdanikzpq.supabase.co/storage/v1/object/public/img/userProfileBasic.png?t=2025-01-21T18%3A49%3A17.726Z")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(user.name ?? "Unknown")
                    .font(.headline)
                Text(user.surname ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    UsersView()
        .environment(Preview.vm())
        .environmentObject(Preview.tabViewModel)
}
