//
//  ClassAddView.swift
//  Ralpher
//
//  Created by Jose Decena on 18/1/25.
//

import SwiftUI

struct ClassAddView: View {
    @Environment(ViewModel.self) var vm
    @Environment(ContenedorSchool.self) var school
    
    @State private var name: String = ""
    @State private var color: Color = .white
    @State private var timePerWeek: Int = 1 // Valor predeterminado para horas por semana

    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                Form {
                    // Sección para el nombre de la clase
                    Section(header: Text("Class Details")) {
                        TextField("Name", text: $name)
                    }
                    
                    // Sección para elegir el color
                    Section(header: Text("Color")) {
                        ColorPicker("Color", selection: $color)
                    }
                    
                    // Sección para horas por semana
                    Section(header: Text("Time Per Week")) {
                        Stepper(value: $timePerWeek, in: 1...40) {
                            Text("\(timePerWeek) hour(s) per week")
                        }
                    }
                }
            }
            .navigationTitle("Add Class")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        //createClass()
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
        .environment(Preview.vm)
        .environment(ContenedorSchool(schools: .init(name: "SchoolPreview")))
}
