//
//  ViewModel.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 10/12/24.
//

import Foundation
import SwiftUI
import Supabase
import GoogleSignIn

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://xvkymhtcipdbdanikzpq.supabase.co")!,
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2a3ltaHRjaXBkYmRhbmlrenBxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM4NTU1MjksImV4cCI6MjA0OTQzMTUyOX0.sYVHSRdm1cEv4Vydp2lsmngmD3aBG-bBOW61raBnhe4"
)

@Observable
@MainActor
final class ViewModel: ObservableObject {

    var users: UserModel?
    var schools: [SchoolsModel]?
    var isAuthenticated: Bool?
    
    var channelUser: RealtimeChannelV2?
    var channelSchools: RealtimeChannelV2?
    
    init(users: UserModel? = nil, schools: [SchoolsModel]? = nil, isAuthenticated: Bool? = nil, channelUser: RealtimeChannelV2? = nil) {
        self.users = users
        self.schools = schools
        self.isAuthenticated = isAuthenticated
        self.channelUser = channelUser
        Task {
            await subscribeToUserUpdates()
        }
        Task {
            await subscribeToSchoolsUpdates()
        }
    }
    
}

