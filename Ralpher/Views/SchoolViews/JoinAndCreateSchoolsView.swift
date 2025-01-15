//
//  JoinAndCreateSchoolsView.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 18/12/24.
//

import SwiftUI

struct JoinAndCreateSchoolsView: View {
    
    @Binding var isPresent: Bool
    
    var body: some View {
        TabView {
            TabView {
                JoinSchoolView(isPresented: $isPresent)
                
            }
            TabView {
                SchoolCreateView(isPresented: $isPresent)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
}

#Preview {
    JoinAndCreateSchoolsView(isPresent: .constant(true))
        .environment(Preview.vm)
}
