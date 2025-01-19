//
//  ClassView.swift
//  Ralpher
//
//  Created by Jose Decena on 18/1/25.
//

import SwiftUI

struct ClassView: View {
    @Environment(ViewModel.self) var vm
    
    @State private var isAdd: Bool = false
    
    var body: some View {
        NavigationStack {
            if let classM = vm.classM, !classM.isEmpty {
                LazyAdapList(preferredWidth: 250) {
                    ForEach(classM) { classModel in
                        NavigationLink {
                            SelectedClassView()
                        } label: {
                            ClassPreview(classModel: classModel)
                                .frame(width: 250, height: 250)
                        }
                    }
                }
                .onAppear {
                    Task { do { try await vm.fetchClass() } catch { print(error) } }
                }
                .padding(7)
                .navigationBarTitle("Class")
                .toolbar(content: {
                    Button("Add Class") {
                        isAdd = true
                    }
                })
                .sheet(isPresented: $isAdd) {
                    ClassAddView(isPresented: $isAdd)
                }
            } else {
                Text("There are no classes")
                    .onAppear {
                        Task { do { try await vm.fetchClass() } catch { print(error) } }
                    }
                    .navigationBarTitle("Class")
                    .toolbar(content: {
                        Button("Add Class") {
                            isAdd = true
                        }
                    })
                    .sheet(isPresented: $isAdd) {
                        ClassAddView(isPresented: $isAdd)
                    }
                Button {
                    Task { do { try await vm.fetchClass() } catch { print(error) } }
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
    ClassView()
        .environment(Preview.vm)
}
