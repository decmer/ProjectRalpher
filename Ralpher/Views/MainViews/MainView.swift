//
//  MainView.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 11/12/24.
//

import SwiftUI

class TabViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
}

struct MainView: View {
    @Environment(ViewModel.self) var vm
    
    @State var sessionRetry = false
    @StateObject var tabViewModel = TabViewModel()

    var body: some View {
        if let isAuthenticated = vm.isAuthenticated {
            if isAuthenticated {
                TabView(selection: $tabViewModel.selectedTab) {
                    SchoolView()
                        .environmentObject(tabViewModel)
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                        .tag(0)

                    CalendarView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Calendar")
                        }
                        .tag(1)

                    SettingsView()
                        .tabItem {
                            Image(systemName: "gearshape")
                            Text("Settings")
                        }
                        .tag(2)
                }
                .modifier(FloatingMessageModifier())
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
                            vm.isAuthenticated = false
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
                            vm.isAuthenticated = false
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
