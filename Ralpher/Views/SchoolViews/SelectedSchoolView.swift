//
//  SelectedSchoolView.swift
//  Ralpher
//
//  Created by Jose Decena on 18/1/25.
//

import SwiftUI

struct SelectedSchoolView: View {
    @Environment(ViewModel.self) var vm

    struct NavigationItem: Hashable {
        var title: String
        var symbolName: String
        var destination: AnyView
        
        func hash(into hasher: inout Hasher) {
                hasher.combine(title)
                hasher.combine(symbolName)
            }

            static func == (lhs: NavigationItem, rhs: NavigationItem) -> Bool {
                lhs.title == rhs.title && lhs.symbolName == rhs.symbolName
            }
    }
    
    let name: String
    
    @State var titles: [NavigationItem] = [
        NavigationItem(title: "Class", symbolName: "graduationcap", destination: AnyView(ClassView())),     // Clases
        NavigationItem(title: "Users", symbolName: "person.2", destination: AnyView(UsersView())),          // Usuarios
        NavigationItem(title: "Schedule", symbolName: "calendar", destination: AnyView(ScheduleView())),        // Horario
        NavigationItem(title: "Release", symbolName: "arrow.up.circle", destination: AnyView(Text("Release"))),     // comunicados
        NavigationItem(title: "Fouls", symbolName: "exclamationmark.circle", destination: AnyView(Text("Fouls"))),      // Faltas
        NavigationItem(title: "Information", symbolName: "info.circle", destination: AnyView(InformationView())),       // Informacion
        NavigationItem(title: "Incidents", symbolName: "exclamationmark.triangle", destination: AnyView(Text("Incidents"))),        // Incidentes
        NavigationItem(title: "Courses", symbolName: "person.3.sequence.fill", destination: AnyView(CoursesView())),      // Cursos
        NavigationItem(title: "school grades", symbolName: "person.3.sequence.fill", destination: AnyView(Text("school grades")))   // Calificaciones
    ]
        
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach($titles, id: \.self) { title in
                            if let role = vm.roleSchoolSelected {
                                switch role {
                                case .manager, .admin:
                                    if title.title.wrappedValue != "school grades" {
                                        if title.title.wrappedValue == "Courses" {
                                            item(title.title.wrappedValue, nameSimbol: title.symbolName.wrappedValue, view: title.destination.wrappedValue, width: geometry.size.width, height: geometry.size.height)
                                                .onAppear(perform: { vm.userToCourse = nil })
                                        } else {
                                            item(title.title.wrappedValue, nameSimbol: title.symbolName.wrappedValue, view: title.destination.wrappedValue, width: geometry.size.width, height: geometry.size.height)
                                        }
                                    }
                                    
                                case .teacher:
                                    if title.title.wrappedValue != "Courses" && title.title.wrappedValue != "Information" && title.title.wrappedValue != "school grades" {
                                        item(title.title.wrappedValue, nameSimbol: title.symbolName.wrappedValue, view: title.destination.wrappedValue, width: geometry.size.width, height: geometry.size.height)
                                    }
                                case .student:
                                    if title.title.wrappedValue != "Courses" && title.title.wrappedValue != "Users" && title.title.wrappedValue != "Information" {
                                        item(title.title.wrappedValue, nameSimbol: title.symbolName.wrappedValue, view: title.destination.wrappedValue, width: geometry.size.width, height: geometry.size.height)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top)
                    Spacer()
                }
                .onAppear {
                    Task { do { try await vm.fetchClass() } catch { vm.messageError = error.localizedDescription } }
                }
                .overlay {
                    VStack {
                        Spacer()
                        if let role = vm.roleSchoolSelected?.rawValue {
                            Text("role: \(role)")
                                .font(.caption2)
                                .padding()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(name)
        }
    }
    
    func item(_ name: String, nameSimbol: String, view: some View, width: CGFloat, height: CGFloat)-> some View {
        NavigationLink {
            view
        } label: {
            itemview(name, nameSimbol: nameSimbol, width: width, height: height)
        }
        .padding()
    }
    
    func itemview(_ name: String, nameSimbol: String, width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 7)
            .frame(width: CGFloat(Int(width*0.38)), height: CGFloat(Int(height > 1100 ? height*0.17 : height*0.14)))
            .foregroundStyle(LinearGradient.harmoniousGradient(baseColor: Color(hex: (vm.schoolSelected?.color ?? Color.blue.toHex())!)))
            .overlay {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: nameSimbol)
                            .foregroundStyle(Color(hex: (vm.schoolSelected?.color ?? Color.blue.toHex())!).contrastingColor())
                        Text(name)
                            .font(.headline)
                            .foregroundStyle(Color(hex: (vm.schoolSelected?.color ?? Color.blue.toHex())!).contrastingColor())
                    }
                    Spacer()
                }
            }
        
    }
    
//    var progress: Double {
//        let totalVariables = 3.0
//        let filledVariables = [vm.userToSchool, vm.roleSchoolSelected, vm.schoolSelected].compactMap { $0 }.count
//        return Double(filledVariables) / totalVariables
//    }
//    
    var progress: Double {
        var count = 0
        if vm.userToSchool != nil { count += 1 }
        if vm.roleSchoolSelected != nil { count += 1 }
        if vm.schoolSelected != nil { count += 1 }
        return Double(count) / 3.0
    }
}

#Preview {
    SelectedSchoolView(name: "pepe")
        .environment(Preview.vm())
}
