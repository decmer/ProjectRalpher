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
    @State var roleAux: RoleSchool
    @State var lastRole: RoleSchool
    @State var showAlert = false
    @State var option: OptionProfileView = .fouls
    
    init(user: UserModel, role: RoleSchool) {
        self.user = user
        self.role = role
        roleAux = role
        lastRole = role
    }
    
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
                    .font(.title2)
                
                Picker("Role", selection: $role) {
                    ForEach(RoleSchool.allCases.filter({ RoleSchool in
                        (vm.roleSchoolSelected == .admin && RoleSchool != .manager) || vm.roleSchoolSelected == .manager
                    }), id: \.self) { role in
                        Text(role.rawValue).tag(role)
                    }
                }
                .onChange(of: role) { oldValue, newValue in
                    if roleAux != newValue {
                        self.roleAux = oldValue
                        showAlert = true
                    }
                }
                .alert("Are you sure?", isPresented: $showAlert) {
                    Button("Yes", role: .destructive) {
                        Task {
                            do {
                                try await vm.updateUserRole(userId: user.id, newRole: role.rawValue)
                                roleAux = role
                                lastRole = role
                            } catch {
                                role = roleAux
                                vm.messageError = error.localizedDescription
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        role = roleAux
                    }
                } message: {
                    Text("Do you want to change your role to \(role.rawValue)?")
                }

                
                
                if lastRole == .student {
                    Picker("Role", selection: $option) {
                        ForEach(OptionProfileView.allCases, id: \.self) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    switch option {
                    case .fouls:
                        FoulsView()
                            .padding()
                    case .release:
                        ReleaseView()
                            .padding()
                    case .schoolGrades:
                        SchoolGradesView()
                            .padding()
                    case .incidents:
                        IncidentsView()
                            .padding()
                    }
                    
                    Spacer()
                }
            }
            .toolbar {
                if isPermisedToDeleteUserSchool() {
                    Button {
                        Task {
                            do {
                                try await vm.deleteUserSchool(user)
                            } catch {
                                vm.messageError = error.localizedDescription
                            }
                        }
                    } label: {
                        Text("Expel \(roleAux.rawValue)")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
        }
    }
    
    func isPermisedToDeleteUserSchool() -> Bool {
        if  let myRole = vm.roleSchoolSelected, role == .manager, myRole == .manager || myRole == .admin {
            return false
        }
        return true
    }
    
    enum OptionProfileView: String, CaseIterable, Hashable {
        case fouls
        case release
        case schoolGrades
        case incidents
    }
}

#Preview {
    UserView(user: .init(id: .init(), name: "jose", surname: "decena"), role: .student)
        .environment(Preview.vm())
}
