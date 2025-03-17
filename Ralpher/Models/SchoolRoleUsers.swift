//
//  SchoolRoleUsers.swift
//  Ralpher
//
//  Created by Jose Merino Decena on 17/3/25.
//

import Foundation

struct SchoolRoleUsers: Hashable {
    let school: SchoolsModel
    let role: RoleSchool
    let users: [(UserModel, RoleSchool)]

    func hash(into hasher: inout Hasher) {
        hasher.combine(school.id)
    }

    static func == (lhs: SchoolRoleUsers, rhs: SchoolRoleUsers) -> Bool {
        return lhs.school.id == rhs.school.id
    }
}
