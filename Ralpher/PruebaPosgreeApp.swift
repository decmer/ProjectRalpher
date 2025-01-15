//
//  PruebaPosgreeApp.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 10/12/24.
//

import SwiftUI
import GoogleSignIn

@main
struct PruebaPosgreeApp: App {

    @State var vm = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(vm)
        }
    }
}
