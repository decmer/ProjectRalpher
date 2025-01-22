//
//  MainView.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 11/12/24.
//

import SwiftUI

struct MainView: View {
    @Environment(ViewModel.self) var vm
    
    @State var sessionRetry = false

    var body: some View {
        if let isAuthenticated = vm.isAuthenticated {
            if isAuthenticated {
                TabView {
                    Tab {
                        SchoolView()
                    } label: {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    
                    Tab {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                }
            } else {
                UserAuthenticationView()
            }
        } else {
            ProgressView()
                .onAppear {
                    Task {
                        do {
                            try await vm.restoreSession()
                        } catch {
                            
                        }
                    }
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
                        DispatchQueue.main.sync {
                            withAnimation {
                                sessionRetry = true
                            }
                        }
                    }
                }
            if sessionRetry {
                Button("Retry", action: {
                    Task {
                        do {
                            try await vm.restoreSession()
                        } catch {
                            
                        }
                    }
                })
            }
        }
            
    }
}

#Preview {
    MainView()
        .environment(Preview.vm())
}
