//
//  ClassAddView.swift
//  Ralpher
//
//  Created by Jose Decena on 18/1/25.
//

import SwiftUI

struct ClassAddView: View {
    @Environment(ViewModel.self) var vm
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var color: Color = .white
    @State private var timePerWeek: Int = 1 // Valor predeterminado para horas por semana
//    @State private var specifiedForCourse = false

    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            Form {
                // Sección para el nombre de la clase
                Section(header: Text("Class Details")) {
                    TextField("Name", text: $name)
                    ColorPicker("Color", selection: $color)
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 60)
                }
//                Toggle(isOn: $specifiedForCourse) {
//                    Text("Class specified for course")
//                }
//                if specifiedForCourse {
//                    Section(header: Text("Time Per Week")) {
//                        Stepper(value: $timePerWeek, in: 1...40) {
//                            Text("\(timePerWeek) hour(s) per week")
//                        }
//                    }
//                }
            }
            .navigationTitle("Add Class")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            do {
                                try await vm.createClass(.init(name: name, description: description, id_school: vm.schoolSelected?.id, color: color.toHex(), timeperweek: timePerWeek))
                                isPresented = false
                            } catch {
                                vm.messageError = error.localizedDescription
                            }
                        }
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var bool = true
    ClassAddView(isPresented: $bool)
        .environment(Preview.vm())
}
