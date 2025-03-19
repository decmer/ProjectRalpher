//
//  classModels.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 11/12/24.
//

import Foundation

struct ClassModel: Identifiable, Decodable, Encodable, Hashable {
    var id: Int?
    var name: String
    var description: String?
    var id_school: Int?
    var color: String?
    var timeperweek: Int?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ClassModel, rhs: ClassModel) -> Bool {
        return lhs.id == rhs.id
    }
}
