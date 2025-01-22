//
//  Users.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 11/12/24.
//

import Foundation

struct UserModel: Identifiable, Decodable, Encodable {
    var id: UUID
    var name: String?
    var surname: String?
    var imgname: String?
    var imgurl: String?
}

enum RoleSchool: String, CaseIterable {
    case manager
    case admin
    case teacher
    case student
}
