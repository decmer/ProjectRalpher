//
//  ClassView.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 14/12/24.
//

import SwiftUI

struct UsersView: View {
    @Environment(ViewModel.self) private var vm
    
    var groupedUsers: [RoleSchool: [UserModel]] {
        guard let userToSchool = vm.userToSchool else { return [:] }
        return Dictionary(grouping: userToSchool.map { $0.0 }, by: { pair in
            userToSchool.first(where: { $0.0.id == pair.id })?.1 ?? .student
        })
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(RoleSchool.allCases, id: \.self) { role in
                    if let users = groupedUsers[role], !users.isEmpty {
                        Section(header: Text(role.rawValue.capitalized)) {
                            ForEach(users) { user in
                                userPreview(user: user)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Users by Role")
        }
    }
    
    func userPreview(user: UserModel) -> some View {
        HStack {
            AsyncImage(url: URL(string: vm.users?.imgurl ?? "https://xvkymhtcipdbdanikzpq.supabase.co/storage/v1/object/public/img/userProfileBasic.png?t=2025-01-21T18%3A49%3A17.726Z")) { image in
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
}
