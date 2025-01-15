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
    
    var body: some View {
        NavigationStack {
            if let schools = vm.schools {
                ScrollView {
                    LazyVGrid(columns: [GridItem()]) {
                        ForEach(schools) { school in
                            SchoolPreview(model: school)
                                .frame(width: 350, height: 200)
                                .padding(.vertical, 12)
                        }
                    }
                }
                .navigationTitle("Schools")
                .toolbar {
                    ToolbarItem {
                        Button {
                            isPresentedCreateView = true
                        } label: {
                            Text("add")
                        }

                    }
                }
                .refreshable { Task { do { try await vm.fetchSchools() } catch { print(error) } } }
                .sheet(isPresented: $isPresentedCreateView) {
                    JoinAndCreateSchoolsView(isPresent: $isPresentedCreateView)
                }
            } else {
                Text("ninguna escuela")
                    .onAppear {
                        Task { do { try await vm.fetchSchools() } catch { print(error) } }
                    }
                    .navigationTitle("Schools")
                    .refreshable { Task { do { try await vm.fetchSchools() } catch { print(error) } } }
            }
            
        }
    }
}

#Preview {
    SchoolView()
        .environment(Preview.vm)
}
