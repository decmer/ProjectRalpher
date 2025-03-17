//
//  SchoolView.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 14/12/24.
//

import SwiftUI

struct SchoolView: View {
    @Environment(ViewModel.self) var vm
    
    @State var isPresentedCreateView: Bool = false
    @State var isPresentedJoinView: Bool = false
    @State var searchableSTR = ""
    
    var schoolFilter: [SchoolsModel]? {
        if vm.schools != nil {
            let filteredSchools: [SchoolsModel] = vm.schools!.filter {
                $0.name.lowercased().contains(searchableSTR.lowercased())
            }
            return filteredSchools
        } else {
            return nil
        }
    }
    
    var body: some View {
        NavigationStack {
            if let schoolsAux = schoolFilter, let schools = vm.schools, !schools.isEmpty {
                    LazyAdapList(preferredWidth: 350) {
                        ForEach(searchableSTR.isEmpty ? schools : schoolsAux) { school in
                            NavigationLink {
                                SelectedSchoolView(name: school.name)
                                    .onAppear {
                                        if let schoolRoolUser = vm.cacheSchools.first(where: { $0.school.id == school.id }) {
                                            vm.schoolSelected = school
                                            vm.roleSchoolSelected = schoolRoolUser.role
                                            vm.userToSchool = schoolRoolUser.users
                                        }
                                    }
                            } label: {
                                SchoolPreview(model: school)
                                    .frame(width: 350, height: 200)
                                    .padding(.vertical, 12)
                            }
                            .onAppear {
                                Task {
                                    do {
                                        if !vm.cacheSchools.contains(where: { SchoolRoleUsers in
                                            SchoolRoleUsers.school.id == school.id
                                        }) {
                                            if let roleSchoolSelected: RoleSchool = try await vm.fetchRoleToSchools(school.id!) {
                                                let userToSchool = try await vm.fetchUseersToSchools(school.id!)
                                                vm.cacheSchools.insert(SchoolRoleUsers(school: school, role: roleSchoolSelected, users: userToSchool))
                                            }
                                        }
                                    } catch {
                                        vm.messageError = error.localizedDescription
                                    }
                                }
                            }
                        }
                        
                    }
                    .searchable(text: $searchableSTR)
                    .onAppear {
                        vm.schoolSelected = nil
                        vm.userToSchool = nil
                        vm.roleSchoolSelected = nil
                    }
                .navigationTitle("Schools")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                isPresentedCreateView = true
                            } label: {
                                Text("Create School")
                            }
                            Button {
                                withAnimation {
                                    isPresentedJoinView = true
                                }
                            } label: {
                                Text("Join School")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .refreshable { Task { do { try await vm.fetchSchools() } catch { vm.messageError = error.localizedDescription } } }
                .sheet(isPresented: $isPresentedCreateView) {
                    SchoolCreateView(isPresented: $isPresentedCreateView)
                }
                .sheet(isPresented: $isPresentedJoinView) {
                    JoinSchoolView(isPresented: $isPresentedJoinView)
                        .presentationDetents([.fraction(0.12)])
                }
                
            } else {
                Text("There are no Schools")
                    .onAppear {
                        Task { do { try await vm.fetchSchools() } catch { vm.messageError = error.localizedDescription } }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button {
                                    isPresentedCreateView = true
                                } label: {
                                    Text("Create School")
                                }
                                Button {
                                    withAnimation {
                                        isPresentedJoinView = true
                                    }
                                } label: {
                                    Text("Join School")
                                }
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $isPresentedCreateView) {
                        SchoolCreateView(isPresented: $isPresentedCreateView)
                    }
                    .sheet(isPresented: $isPresentedJoinView) {
                        JoinSchoolView(isPresented: $isPresentedJoinView)
                            .presentationDetents([.fraction(0.12)])
                    }
                    .navigationTitle("Schools")
                Button {
                    Task { do { try await vm.fetchSchools() } catch { vm.messageError = error.localizedDescription } }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(.blue)
                }
                .padding()
            }
        }
    }
}

#Preview {
    SchoolView()
        .environment(Preview.vm())
}
