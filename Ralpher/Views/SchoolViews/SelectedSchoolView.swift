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
    
    @State var titles: [NavigationItem] = [
        NavigationItem(title: "Class", symbolName: "graduationcap", destination: AnyView(ClassView())),
        NavigationItem(title: "Users", symbolName: "person.2", destination: AnyView(UsersView())),
        NavigationItem(title: "Schedule", symbolName: "calendar", destination: AnyView(ScheduleView())),
        NavigationItem(title: "Release", symbolName: "arrow.up.circle", destination: AnyView(Text("Release"))),
        NavigationItem(title: "Fouls", symbolName: "exclamationmark.circle", destination: AnyView(Text("Fouls"))),
        NavigationItem(title: "Information", symbolName: "info.circle", destination: AnyView(Text("Information"))),
        NavigationItem(title: "Incidents", symbolName: "exclamationmark.triangle", destination: AnyView(Text("Incidents")))
    ]
    
    let color = Color.orange
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                HStack {
                    Spacer()
                    VStack(spacing: 30) {
                        Spacer()
                        LazyAdapList(preferredWidth: 150) {
                            ForEach($titles, id: \.self) { title in
                                item(title.title.wrappedValue, nameSimbol: title.symbolName.wrappedValue, view: title.destination.wrappedValue, width: geometry.size.width)
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                        .navigationTitle(vm.schoolSelected?.name ?? "indefinite")
                }
            }
        }
    }
    
    func item(_ name: String, nameSimbol: String, view: some View, width: CGFloat)-> some View {
        NavigationLink {
            view
        } label: {
            itemview(name, nameSimbol: nameSimbol, width: width)
        }
    }
    
    func itemview(_ name: String, nameSimbol: String, width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 7)
            .frame(width: 150, height: 100)
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
                    Spacer()                }
            }
        
    }
}

#Preview {
    SelectedSchoolView()
        .environment(Preview.vm)
}
