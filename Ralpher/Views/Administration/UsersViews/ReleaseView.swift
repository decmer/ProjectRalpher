//
//  ReleaseView.swift
//  Ralpher
//
//  Created by Jose Decena on 24/1/25.
//

import SwiftUI

struct ReleaseView: View {
    @Environment(ViewModel.self) private var vm
    
    var classModels: [ClassModel] {
        if let classToCourse = vm.classToCourse {
            return classToCourse
        } else {
            return []
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(classModels) { clas in
                    classPreview(clas)
                }
            }
            .background(Color.clear)
            .listStyle(InsetListStyle())
        }
    }
    
    func classPreview(_ clas: ClassModel) -> some View {
        Text(clas.name)
    }
}


#Preview {
    ReleaseView()
}
