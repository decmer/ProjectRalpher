//
//  AddUsersCourseView.swift
//  Ralpher
//
//  Created by Jose Merino Decena on 14/3/25.
//

import SwiftUI

struct AddUsersCourseView: View {
    @Environment(ViewModel.self) private var vm
    
    var groupedUsers: [RoleSchool: [UserModel]] {
        guard let userToSchool = vm.userToSchool else { return [:] }
        guard let userToCourse = vm.userToCourse else {
            return Dictionary(grouping: userToSchool.filter({ (_, roleSchool) in
                (roleSchool != .admin && roleSchool != .manager)
            }).map {$0.0}, by: { pair in
                userToSchool.first(where: { $0.0.id == pair.id })?.1 ?? .student
            })
        }
        let dic = Dictionary(grouping: userToSchool.filter({ (_, roleSchool) in
            (roleSchool != .admin && roleSchool != .manager)
        }).map { $0.0 }.filter({ item in
            return !userToCourse.contains(where: { $0.id == item.id })
        }), by: { pair in
            userToSchool.first(where: { $0.0.id == pair.id })?.1 ?? .student
        })
        return dic
    }
    var functionAdd: (Set<UUID>) -> Void
    @State var addUserModel: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            if groupedUsers.isEmpty {
                VStack {
                    Spacer()
                    Text("No users to add")
                        .font(.headline)
                    Spacer()
                }
            } else {
                List {
                    ForEach(RoleSchool.allCases, id: \.self) { role in
                        if let users = groupedUsers[role], !users.isEmpty {
                            Section(header: Text(role.rawValue.capitalized)) {
                                ForEach(users) { user in
                                    if user.id != vm.users?.id {
                                        userview(user: user, role: role)
                                            .onTapGesture {
                                                if addUserModel.contains(user.id) {
                                                    addUserModel.remove(user.id)
                                                } else {
                                                    addUserModel.insert(user.id)
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
                .background(Color.clear)
                .listStyle(.automatic)
                .toolbar {
                    Button {
                        functionAdd(addUserModel)
                    } label: {
                        Text("Add")
                    }
                    .disabled(addUserModel.isEmpty)

                }
            }
        }
    }
    
    func userview(user: UserModel, role: RoleSchool) -> some View {
        userPreview(user: user, role: role)
    }
    
    func userPreview(user: UserModel, role: RoleSchool) -> some View {
        ZStack {
            Color.clear
                        .contentShape(Rectangle())
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(user.surname ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                ZStack {
                    Circle()
                        .strokeBorder(addUserModel.contains(user.id) ? Color.blue : Color.black.opacity(0.2), lineWidth: 2)
                        .frame(width: 30, height: 30)
                    
                    if addUserModel.contains(user.id) {
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
    AddUsersCourseView { _ in
        
    }
        .environment(Preview.vm())
}
