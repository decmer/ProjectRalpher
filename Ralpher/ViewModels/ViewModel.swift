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
    var schoolSelected: SchoolsModel? = nil {
        willSet {
            classM = nil
        }
        didSet {
            if schoolSelected != nil {
                Task {
                    do {
                        course = try await fetchCourse()
                    } catch {
                        messageError = error.localizedDescription
                    }
                }
            }
        }
    }
    var roleSchoolSelected: RoleSchool?
    var userToSchool: [(UserModel, RoleSchool)]?
    var classM: [ClassModel]?
    var classSelected: ClassModel?
    var course: [CourseModel]?
    var courseSelected: (CourseModel, [UserModel], [ClassModel])?
    var userToCourse: [UserModel]?
    var classToCourse: [ClassModel]?

    
    var isAuthenticated: Bool?
    
    var channelUser: RealtimeChannelV2?
    var channelSchools: RealtimeChannelV2?
    var channelClass: RealtimeChannelV2?
    var channelCourse: RealtimeChannelV2?
    var channelUsersSchool: RealtimeChannelV2?
    
    
    var cacheSchools: [(SchoolsModel, RoleSchool, [(UserModel, RoleSchool)])]
    // var cacheClass: [(SchoolsModel, RoleSchool, [(UserModel, RoleSchool)])]
    var cacheCourse: [(CourseModel, [UserModel], [ClassModel])]
    
    var messageError: String?
    
    
    init(users: UserModel? = nil, schools: [SchoolsModel]? = nil, isAuthenticated: Bool? = nil, channelUser: RealtimeChannelV2? = nil) {
        self.users = users
        self.schools = []
        self.isAuthenticated = isAuthenticated
        self.channelUser = channelUser
        self.cacheSchools = []
        self.cacheCourse = []
        Task {
            await subscribeToUser()
        }
        Task {
            await subscribeToSchools()
        }
        Task {
            await subscribeToClass()
        }
        Task {
            await subscribeToUsersSchools()
        }
        Task {
            await subscribeToCourse()
        }
    }
    
}

