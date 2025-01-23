//
//  UserView.swift
//  Ralpher
//
//  Created by Jose Decena on 23/1/25.
//

import SwiftUI

struct UserView: View {
    @Environment(ViewModel.self) private var vm
    
    @State var user: UserModel
    
    @State var role: RoleSchool
    
    var body: some View {
        NavigationStack {
            VStack {
                AsyncImage(url: URL(string: user.imgurl ?? "https://xvkymhtcipdbdanikzpq.supabase.co/storage/v1/object/public/img/userProfileBasic.png?t=2025-01-21T18%3A49%3A17.726Z")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                
                Text("\(user.name ?? "") \(user.surname ?? "")")
                
                Picker("Role", selection: $role) {
                    ForEach(RoleSchool.allCases, id: \.self) { role in
                        Text(role.rawValue).tag(role)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
}

#Preview {
    UserView(user: .init(id: .init()), role: .admin)
        .environment(Preview.vm())
}
