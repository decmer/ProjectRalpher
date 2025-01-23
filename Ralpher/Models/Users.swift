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

enum RoleSchool: String, CaseIterable, Hashable {
    case manager
    case admin
    case teacher
    case student
}

//enum RoleSchool: String, CaseIterable, Hashable, Identifiable {
//    case manager = "Manager"
//    case admin = "Admin"
//    case teacher = "Teacher"
//    case student = "Student"
//
//    var id: String { self.rawValue } // Para conformar con Identifiable
//}
