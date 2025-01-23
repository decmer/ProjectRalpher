//
//  Preview.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 11/12/24.
//

import Foundation
import SwiftUICore

@MainActor
final class Preview {
    static let vm = {
        var vm = ViewModel()
        vm.schoolSelected = SchoolsModel(id: 197, name: "jose", color: Color.blue.toHex(), image: "")
        vm.userToSchool = [(UserModel, RoleSchool)]()
        vm.userToSchool?.append((.init(id: UUID(), name: "jose Antonio Merinno Decena"), .manager))
        vm.userToSchool?.append((.init(id: UUID(), name: "jorge frnandez genicio"), .admin))
        vm.userToSchool?.append((.init(id: UUID(), name: "Pablo de los santos"), .student))
        vm.userToSchool?.append((.init(id: UUID(), name: "Pablo Merino"), .student))
        vm.userToSchool?.append((.init(id: UUID(), name: "Adrian senrra"), .admin))
        vm.userToSchool?.append((.init(id: UUID(), name: "maria montewey ortiz diaz"), .student))
        vm.userToSchool?.append((.init(id: UUID(), name: "david dominges mejia"), .teacher))
        vm.userToSchool?.append((.init(id: UUID(), name: "Margaret de la torre"), .teacher))
        vm.userToSchool?.append((.init(id: UUID(), name: "Francisco jimenez clavijo"), .teacher))
        vm.userToSchool?.append((.init(id: UUID(), name: "jose rueda sanchez"), .teacher))
        vm.userToSchool?.append((.init(id: UUID(), name: "Juancarlos salazar holmo"), .teacher))
        vm.roleSchoolSelected = .student
        return vm
    }

}

//
//<key>GIDClientID</key>
//<string>1030569269640-cuj6tnd6a69l5te8hn8s9ecnpdbcpqiu.apps.googleusercontent.com</string>
//<key>CFBundleURLTypes</key>
//<array>
//  <dict>
//    <key>CFBundleURLSchemes</key>
//    <array>
//      <string>com.googleusercontent.apps.1030569269640-cuj6tnd6a69l5te8hn8s9ecnpdbcpqiu</string>
//    </array>
//  </dict>
//</array>
