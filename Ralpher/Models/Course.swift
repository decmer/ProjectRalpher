//
//  Course.swift
//  Ralpher
//
//  Created by Jose Decena on 23/1/25.
//

import Foundation

struct CourseModel: Identifiable, Decodable, Encodable {
    var id: Int?
    var id_school: Int?
    var name: String
}
