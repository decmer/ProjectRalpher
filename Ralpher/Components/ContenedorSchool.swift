//
//  ContenedorSchool.swift
//  Ralpher
//
//  Created by Jose Decena on 18/1/25.
//

import Foundation
import SwiftUI

@Observable
final class ContenedorSchool: Codable {
    var schools: SchoolsModel
    
    init(schools: SchoolsModel) {
        self.schools = schools
    }
}
