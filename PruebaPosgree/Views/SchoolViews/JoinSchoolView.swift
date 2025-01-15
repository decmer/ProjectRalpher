//
//  JoinSchoolView.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 18/12/24.
//

import SwiftUI

struct JoinSchoolView: View {
    @Environment(ViewModel.self) private var vm

    @State var codeJoinSchool: String = ""
    
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            
            TextField("Code to join", text: $codeJoinSchool)
                .padding()
            
            Button("Join") {
                Task {
                    do {
                        try await vm.addUserToSchool(codeJoinSchool)
                        isPresented = false
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            }
        }
    }
}

#Preview {
    JoinSchoolView(isPresented: .constant(true))
        .environment(Preview.vm)
}
