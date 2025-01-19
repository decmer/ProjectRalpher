//
//  classModels.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 11/12/24.
//

import Foundation

struct ClassModel: Identifiable, Decodable, Encodable {
    var id: Int?
    var name: String
    var description: String?
    var id_school: Int?
    var color: String?
    var timeperweek: Int?
}
