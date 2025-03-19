//
//  ReleaseView.swift
//  Ralpher
//
//  Created by Jose Decena on 24/1/25.
//

import SwiftUI

struct ReleaseView: View {
    @Environment(ViewModel.self) private var vm
    
    var body: some View {
        Text("ReleaseView")
    }
}


#Preview {
    ReleaseView()
        .environment(Preview.vm())
}
