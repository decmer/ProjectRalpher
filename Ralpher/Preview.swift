//
//  Preview.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 11/12/24.
//

import Foundation
import SwiftUI

@MainActor
final class Preview {
    static let vm = {
        var vm = ViewModel()
        let user: UserModel = .init(id: UUID(), name: "jose Antonio Merinno Decena")
        vm.schoolSelected = SchoolsModel(id: 197, name: "jose", color: Color.blue.toHex(), imgurl:
//                                            nil)
                                            "https://xvkymhtcipdbdanikzpq.supabase.co/storage/v1/object/public/img//21EAA953-B686-4DA3-8847-D3D7B17C7852")
        vm.schools = [SchoolsModel(id: 197, name: "jose", color: Color.blue.toHex(), imgurl: ""), SchoolsModel(id: 197, name: "jorge", color: Color.green.toHex(), imgurl: ""), SchoolsModel(id: 198, name: "maria", color: Color.red.toHex(), imgurl: ""), SchoolsModel(id: 199, name: "David", color: Color.orange.toHex(), imgurl: ""), SchoolsModel(id: 200, name: "Pablo", color: Color.yellow.toHex(), imgurl: ""), SchoolsModel(id: 197, name: "jorge", color: Color.green.toHex(), imgurl: ""), SchoolsModel(id: 198, name: "maria", color: Color.red.toHex(), imgurl: ""), SchoolsModel(id: 199, name: "David", color: Color.orange.toHex(), imgurl: ""), SchoolsModel(id: 200, name: "Pablo", color: Color.yellow.toHex(), imgurl: ""), SchoolsModel(id: 197, name: "jorge", color: Color.green.toHex(), imgurl: ""), SchoolsModel(id: 198, name: "maria", color: Color.red.toHex(), imgurl: ""), SchoolsModel(id: 199, name: "David", color: Color.orange.toHex(), imgurl: ""), SchoolsModel(id: 200, name: "Pablo", color: Color.yellow.toHex(), imgurl: ""), SchoolsModel(id: 197, name: "jorge", color: Color.green.toHex(), imgurl: ""), SchoolsModel(id: 198, name: "maria", color: Color.red.toHex(), imgurl: ""), SchoolsModel(id: 199, name: "David", color: Color.orange.toHex(), imgurl: ""), SchoolsModel(id: 200, name: "Pablo", color: Color.yellow.toHex(), imgurl: ""), SchoolsModel(id: 197, name: "jorge", color: Color.green.toHex(), imgurl: ""), SchoolsModel(id: 198, name: "maria", color: Color.red.toHex(), imgurl: ""), SchoolsModel(id: 199, name: "David", color: Color.orange.toHex(), imgurl: ""), SchoolsModel(id: 200, name: "Pablo", color: Color.yellow.toHex(), imgurl: "")]
        vm.userToSchool = [(UserModel, RoleSchool)]()
        vm.users = user
        vm.userToSchool?.append((user, .manager))
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
        vm.roleSchoolSelected = .manager
        vm.course = [CourseModel]()
        vm.course?.append(.init(id: 1, name: "Jose"))
        vm.course?.append(.init(id: 2, name: "Jorge"))
        vm.course?.append(.init(id: 3, name: "maria"))
        vm.course?.append(.init(id: 4, name: "David"))
        vm.course?.append(.init(id: 5, name: "Pablo"))
        vm.course?.append(.init(id: 6, name: "Juan"))
        vm.course?.append(.init(id: 7, name: "Cristian"))
        vm.classM = []
        vm.classM?.append(.init(id: 1, name: "Refurezo mates"))
        vm.classM?.append(.init(id: 1, name: "Extraordinarias"))
        vm.classM?.append(.init(id: 1, name: "Futbol"))
        vm.classM?.append(.init(id: 1, name: "1A"))
        vm.classM?.append(.init(id: 1, name: "1B"))
        vm.classM?.append(.init(id: 1, name: "1C"))
        vm.classM?.append(.init(id: 1, name: "2A"))
        vm.classM?.append(.init(id: 1, name: "2B"))
        vm.classM?.append(.init(id: 1, name: "3A"))
        vm.classM?.append(.init(id: 1, name: "3B"))
        vm.classM?.append(.init(id: 1, name: "3C"))
        vm.classM?.append(.init(id: 1, name: "4A"))
        vm.classM?.append(.init(id: 1, name: "4B"))
        vm.userToCourse = [.init(id: UUID(), name: "jorge frnandez genicio"), .init(id: UUID(), name: "Pablo de los santos"), .init(id: UUID(), name: "Pablo Merino"), .init(id: UUID(), name: "Adrian senrra"), .init(id: UUID(), name: "maria montewey ortiz diaz"), .init(id: UUID(), name: "david dominges mejia"), .init(id: UUID(), name: "Margaret de la torre"), .init(id: UUID(), name: "Francisco jimenez clavijo"), .init(id: UUID(), name: "jose rueda sanchez"), .init(id: UUID(), name: "Juancarlos salazar holmo")]
        vm.userToSchool = [(.init(id: UUID(), name: "jorge frnandez genicio"), .admin), (.init(id: UUID(), name: "Pablo de los santos"), .manager), (.init(id: UUID(), name: "Pablo Merino"), .student), (.init(id: UUID(), name: "Adrian senrra"), .teacher), (.init(id: UUID(), name: "maria montewey ortiz diaz"), .admin), (.init(id: UUID(), name: "david dominges mejia"), .manager), (.init(id: UUID(), name: "Margaret de la torre"), .student), (.init(id: UUID(), name: "Francisco jimenez clavijo"), .teacher)]
        vm.courseSelected = (CourseModel(id: 1, name: "Curso"), vm.userToCourse!, vm.classM!)
        return vm
    }
    
    static let tabViewModel = TabViewModel()

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
