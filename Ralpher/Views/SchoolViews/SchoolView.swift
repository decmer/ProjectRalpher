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
                ScrollView {
                    LazyVGrid(columns: [GridItem()]) {
                        ForEach(schools) { school in
                            NavigationLink {
                                SelectedSchoolView()
                                    .onAppear {
                                        vm.schoolSelected = school
                                    }
                            } label: {
                                SchoolPreview(model: school)
                                    .frame(width: 350, height: 200)
                                    .padding(.vertical, 12)
                            }
                        }
                    }
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
                .refreshable { Task { do { try await vm.fetchSchools() } catch { print(error) } } }
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
                        Task { do { try await vm.fetchSchools() } catch { print(error) } }
                    }
                    .navigationTitle("Schools")
                Button {
                    Task { do { try await vm.fetchSchools() } catch { print(error) } }
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
        .environment(Preview.vm)
}
