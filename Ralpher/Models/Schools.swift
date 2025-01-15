//
//  schools.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 11/12/24.
//

import Foundation

struct SchoolsModel: Identifiable, Decodable, Encodable {
    var id: Int?
    var name: String
    var color: String?
    var image: String?
}
