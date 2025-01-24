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
    
    var body: some View {
        NavigationStack {
            if let schools = vm.schools, !schools.isEmpty {
                    LazyAdapList(preferredWidth: 350) {
                        ForEach(schools) { school in
                            NavigationLink {
                                SelectedSchoolView(name: school.name)
                                    .onAppear {
                                        if let index = vm.cache.firstIndex(where: { $0.0.id == school.id! }) {
                                            vm.schoolSelected = school
                                            vm.roleSchoolSelected = vm.cache[index].1
                                            vm.userToSchool = vm.cache[index].2
                                        }
                                    }
                            } label: {
                                SchoolPreview(model: school)
                                    .frame(width: 350, height: 200)
                                    .padding(.vertical, 12)
                            }
                            .onDisappear {
                                Task {
                                    if let index = vm.cache.firstIndex(where: { $0.0.id == school.id! }) {
                                        vm.cache.remove(at: index)
                                    }
                                }
                            }
                            .onAppear {
                                Task {
                                    do {
                                        let userToSchool = try await vm.fetchUseersToSchools(school.id!)
                                        let roleSchoolSelected: RoleSchool = try await vm.fetchRoleToSchools(school.id!) ?? .student
                                        vm.cache.append((school, roleSchoolSelected, userToSchool))
                                    } catch {
                                        vm.messageError = error.localizedDescription
                                    }
                                }
                            }
                        }
                    }
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
