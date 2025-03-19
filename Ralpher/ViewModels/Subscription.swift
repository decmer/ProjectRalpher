//
//  Subscription.swift
//  Ralpher
//
//  Created by Jose Decena on 23/1/25.
//

import Foundation
import Realtime
import Supabase
import SwiftUI

extension ViewModel {
    
    func subscribeToUser() async {
        channelUser = await supabase.realtimeV2.channel("users")
                
        guard let channel = channelUser else { return }
        
        //let insertStream = await channel.postgresChange(InsertAction.self, schema: "public", table: "users")
            
        let updateStream = await channel.postgresChange(UpdateAction.self, schema: "public", table: "users")
            
        let deleteStream = await channel.postgresChange(DeleteAction.self, schema: "public", table: "users")
    
        Task {
            for await updateAction in updateStream {
                DispatchQueue.main.async {
                    let oldUser = self.convertDicToUsers(updateAction.oldRecord)
                    if self.users?.id == oldUser.id {
                        let updatedUser = self.convertDicToUsers(updateAction.record)
                        self.users = updatedUser
                    }
                    if let usersToSchool = self.userToSchool {
                        self.userToSchool = usersToSchool.map { (user, role) in
                            if user.id == oldUser.id {
                                return (self.convertDicToUsers(updateAction.record), role)
                            }
                            return (user, role)
                        }
                    }
                }
                
            }
        }
    
        Task {
            for await deleteAction in deleteStream {
                DispatchQueue.main.async {
                    let oldUser = self.convertDicToUsers(deleteAction.oldRecord)
                    if self.users?.id == oldUser.id {
                        self.users = nil
                        Task {
                            do {
                                try await self.logoutUser()
                            } catch {
                                self.messageError = error.localizedDescription
                            }
                        }
                    } else if let usersToSchool = self.userToSchool {
                        self.userToSchool = usersToSchool.filter { (user, role) in
                            if user.id == oldUser.id {
                                return false
                            }
                            return true
                        }
                    }
                }
            }
        }

        await channel.subscribe()
    }
    
    func subscribeToSchools() async {
        channelSchools = await supabase.realtimeV2.channel("schools")
                
        guard let channel = channelSchools else { return }
        
        let insertStream = await channel.postgresChange(InsertAction.self, schema: "public", table: "schools")
            
        let updateStream = await channel.postgresChange(UpdateAction.self, schema: "public", table: "schools")
            
        let deleteStream = await channel.postgresChange(DeleteAction.self, schema: "public", table: "schools")

        Task {
            for await insertAction in insertStream {
                DispatchQueue.main.async {
                    self.schools?.append(self.convertDicToSchools(insertAction.record))
                }
            }
        }
    
        Task {
            for await updateAction in updateStream {
                let updatedSchool = self.convertDicToSchools(updateAction.record)
                let oldSchool = self.convertDicToSchools(updateAction.oldRecord)
                DispatchQueue.main.async {
                    if let index = self.schools?.firstIndex(where: { $0.id == oldSchool.id }) {
                        self.schools?[index] = updatedSchool
                    }
                }
                if let x = self.cacheSchools.first(where: { SchoolRoleUsers in
                    SchoolRoleUsers.school.id == oldSchool.id
                }) {
                    self.cacheSchools.remove(x)
                }
            }
        }
    
        Task {
            for await deleteAction in deleteStream {
                let idSchool = self.convertDicToSchools(deleteAction.oldRecord).id
                DispatchQueue.main.async {
                    self.schools?.removeAll(where: { SchoolsModel in
                        idSchool == SchoolsModel.id
                    })
                }
                if let x = self.cacheSchools.first(where: { SchoolRoleUsers in
                    SchoolRoleUsers.school.id == idSchool
                }) {
                    self.cacheSchools.remove(x)
                }
            }
        }

        await channel.subscribe()
    }
    
    func subscribeToUsersSchools() async {
        channelUsersSchool = await supabase.realtimeV2.channel("users_schools")
                
        guard let channel = channelUsersSchool else { return }
        
        let insertStream = await channel.postgresChange(InsertAction.self, schema: "public", table: "users_schools")
            
        let updateStream = await channel.postgresChange(UpdateAction.self, schema: "public", table: "users_schools")
            
        let deleteStream = await channel.postgresChange(DeleteAction.self, schema: "public", table: "users_schools")

        Task {
            for await insertAction in insertStream {
                let newUserSchool = await self.convertDicToUsersSchools(insertAction.record)
                if self.userToSchool != nil {
                    if let newUserSchool = newUserSchool, newUserSchool.2 == self.schoolSelected?.id {
                        withAnimation {
                            self.userToSchool?.append((newUserSchool.0, newUserSchool.1))
                        }
                    }
                }
                if newUserSchool?.0.id == self.users?.id {
                    do {
                        try await fetchSchools()
                    } catch {
                        messageError = error.localizedDescription
                    }
                }
            }
        }
    
        Task {
            for await updateAction in updateStream {
                if let newUserSchool = await self.convertDicToUsersSchools(updateAction.record) {
                    if self.userToSchool != nil {
                        if newUserSchool.2 == self.schoolSelected?.id {
                            let userToSchool = self.userToSchool?.map({ (user, role) in
                                if user.id == newUserSchool.0.id {
                                    return (newUserSchool.0, newUserSchool.1)
                                } else {
                                    return (user, role)
                                }
                            })
                            withAnimation {
                                self.userToSchool = userToSchool
                            }
                        }
                    }
                    if let user = self.users, let schoolSelected = self.schoolSelected, user.id == newUserSchool.0.id, user.id == newUserSchool.0.id, schoolSelected.id == newUserSchool.2 {
                        withAnimation {
                            self.roleSchoolSelected = newUserSchool.1
                        }
                    }
                    if let x = self.cacheSchools.first(where: { SchoolRoleUsers in
                        SchoolRoleUsers.school.id == newUserSchool.2
                    }) {
                        self.cacheSchools.remove(x)
                    }
                }
            }
        }
    
        Task {
            for await dic in deleteStream {
//                if self.userToSchool != nil {
//                    let newUserSchool = await self.convertDicToUsersSchools(deleteAction.oldRecord)
//                    if let newUserSchool = newUserSchool, newUserSchool.2 == self.schoolSelected?.id {
//                        self.userToSchool?.removeAll(where: { (user, _) in
//                            user.id == newUserSchool.0.id
//                        })
//                    }
//                }
                do {
                    try await fetchSchools()
                    if self.userToSchool != nil, let schoolSelectedID = self.schoolSelected?.id {
                        let userToSchool = try await fetchUseersToSchools(schoolSelectedID)
                        withAnimation {
                            self.userToSchool = userToSchool
                        }
                    }
                } catch {
                    messageError = error.localizedDescription
                }
                if let id = dic.oldRecord["school_id"]?.intValue, let x = self.cacheSchools.first(where: { SchoolRoleUsers in
                    SchoolRoleUsers.school.id == id
                }) {
                    self.cacheSchools.remove(x)
                }
            }
        }

        await channel.subscribe()
    }
    
    func subscribeToClass() async {
        channelClass = await supabase.realtimeV2.channel("class")
                
        guard let channel = channelClass else { return }
        
        let insertStream = await channel.postgresChange(InsertAction.self, schema: "public", table: "class")
            
        let updateStream = await channel.postgresChange(UpdateAction.self, schema: "public", table: "class")
            
        let deleteStream = await channel.postgresChange(DeleteAction.self, schema: "public", table: "class")

            Task {
                for await insertAction in insertStream {
                    DispatchQueue.main.async {
                        if let schoolSelected = self.schoolSelected {
                            let classM = self.convertDicToClass(insertAction.record)
                            if classM.id_school == schoolSelected.id {
                                withAnimation {
                                    self.classM?.append(classM)
                                }
                            }
                        }
                    }
                }
            }
        
            Task {
                for await updateAction in updateStream {
                    DispatchQueue.main.async {
                        if let schoolSelected = self.schoolSelected {
                            let updatedClass = self.convertDicToClass(updateAction.record)
                            if updatedClass.id_school == schoolSelected.id {
                                let oldClass = self.convertDicToClass(updateAction.oldRecord)
                                if let index = self.classM?.firstIndex(where: { $0.id == oldClass.id }) {
                                    withAnimation {
                                        self.classM?[index] = updatedClass
                                    }
                                }
                            }
                        }
                    }
                }
            }
        
            Task {
                for await deleteAction in deleteStream {
                    DispatchQueue.main.async {
                        if let schoolSelected = self.schoolSelected {
                            let classM = self.convertDicToClass(deleteAction.oldRecord)
                            if classM.id_school == schoolSelected.id {
                                let idClass = classM.id
                                self.classM?.removeAll(where: { classModel in
                                    withAnimation {
                                        idClass == classModel.id
                                    }
                                })
                            }
                        }
                        
                        
                    }
                }
            }

            await channel.subscribe()
        }
    
    func subscribeToCourse() async {
        channelCourse = await supabase.realtimeV2.channel("course")
                
        guard let channel = channelCourse else { return }
        
        let insertStream = await channel.postgresChange(InsertAction.self, schema: "public", table: "course")
            
        let updateStream = await channel.postgresChange(UpdateAction.self, schema: "public", table: "course")
            
        let deleteStream = await channel.postgresChange(DeleteAction.self, schema: "public", table: "course")

            Task {
                for await insertAction in insertStream {
                    DispatchQueue.main.async {
                        if let schoolSelected = self.schoolSelected {
                            let course = self.convertDicToCourse(insertAction.record)
                            if course.id_school == schoolSelected.id {
                                withAnimation {
                                    self.course?.append(course)
                                }
                            }
                        }
                    }
                }
            }
        
            Task {
                for await updateAction in updateStream {
                    DispatchQueue.main.async {
                        if let schoolSelected = self.schoolSelected {
                            let updatedCourse = self.convertDicToCourse(updateAction.record)
                            if updatedCourse.id_school == schoolSelected.id {
                                let oldCourse = self.convertDicToCourse(updateAction.oldRecord)
                                if let index = self.course?.firstIndex(where: { $0.id == oldCourse.id }) {
                                    withAnimation {
                                        self.course?[index] = updatedCourse
                                    }
                                }
                            }
                        }
                    }
                }
            }
        
            Task {
                for await _ in deleteStream {
                    if self.schoolSelected != nil {
                        do {
                            let courseAux = try await fetchCourse()
                            withAnimation {
                                self.course = courseAux
                            }
                        } catch {
                            messageError = error.localizedDescription
                        }
                    }
                }
            }
            await channel.subscribe()
        }
    
    
    func subscribeToUserCourse() async {
        channelUserCourse = await supabase.realtimeV2.channel("course_users_school")
                
        guard let channel = channelUserCourse else { return }
        
        let insertStream = await channel.postgresChange(InsertAction.self, schema: "public", table: "course_users_school")
                        
        let deleteStream = await channel.postgresChange(DeleteAction.self, schema: "public", table: "course_users_school")

            Task {
                for await insertAction in insertStream {
                    let dic = insertAction.record
                    let id_course = dic["id_course"]?.intValue
                    let id_school = dic["id_school"]?.intValue
//                        let id_user = UUID(uuidString: dic["user_id"]?.stringValue ?? "")!
                    
                    if let idSchoolSelected = self.schoolSelected?.id, let id_school = id_school, let id_course = id_course, idSchoolSelected == id_school {
                        Task {
                            do {
                                let userToScullAux = try await self.fetchCourseUsersSchool(id_course)
                                DispatchQueue.main.async {
                                    withAnimation {
                                        self.userToCourse = userToScullAux
                                    }
                                }
                            } catch {
                                self.messageError = error.localizedDescription
                            }
                        }
                    }
                }
            }
        
            Task {
                for await deleteAction in deleteStream {
                    let dic = deleteAction.oldRecord
                    let id_course = dic["id_course"]?.intValue
                    let id_school = dic["id_school"]?.intValue
//                        let id_user = UUID(uuidString: dic["user_id"]?.stringValue ?? "")!
                    
                    if let idSchoolSelected = self.schoolSelected?.id, let id_school = id_school, let id_course = id_course, idSchoolSelected == id_school {
                        Task {
                            do {
                                let userToScullAux = try await self.fetchCourseUsersSchool(id_course)
                                DispatchQueue.main.async {
                                    withAnimation {
                                        self.userToCourse = userToScullAux
                                    }
                                }
                            } catch {
                                self.messageError = error.localizedDescription
                            }
                        }
                    }
                }
            }
            await channel.subscribe()
        }
}


extension ViewModel {
    func convertDicToUsers(_ dic: [String: AnyJSON]) -> UserModel {
        let id = dic["id"]?.stringValue ?? ""
        let name = dic["name"]?.stringValue
        let surname = dic["surname"]?.stringValue
        let imgname = dic["imgname"]?.stringValue
        let imgurl = dic["imgurl"]?.stringValue

        let school = UserModel(id: UUID(uuidString: id)!, name: name, surname: surname, imgname: imgname, imgurl: imgurl)
        
        return school
    }
    
    func convertDicToSchools(_ dic: [String: AnyJSON]) -> SchoolsModel {
        let id = dic["id"]?.intValue
        let name = dic["name"]?.stringValue ?? ""
        let color = dic["color"]?.stringValue
        let imgname = dic["imgname"]?.stringValue
        let imgurl = dic["imgurl"]?.stringValue

        let school = SchoolsModel(id: id, name: name, color: color, imgname: imgname, imgurl: imgurl)
        
        return school
    }
    
    func convertDicToUsersSchools(_ dic: [String: AnyJSON]) async -> (UserModel, RoleSchool, Int)? {
        let userID = UUID(uuidString: dic["user_id"]?.stringValue ?? "")!
        let role = dic["role"]?.stringValue ?? ""
        let schoolID = dic["school_id"]?.intValue ?? 0

        do {
            let user = try await fetchUser(id: userID)
            let schoolRole = RoleSchool(rawValue: role)
            if let user = user, let schoolRole = schoolRole {
                return (user, schoolRole, schoolID)
            }
        } catch {
            
        }
        return nil
    }
    
    func convertDicToClass(_ dic: [String: AnyJSON]) -> ClassModel {
        let id = dic["id"]?.intValue
        let id_school = dic["id_school"]?.intValue
        let name = dic["name"]?.stringValue ?? ""
        let description = dic["description"]?.stringValue
        let color = dic["color"]?.stringValue
        let specified_for_course = dic["specified_for_course"]?.boolValue ?? false

        let classM = ClassModel(id: id, name: name, description: description, id_school: id_school, color: color, specified_for_course: specified_for_course)
        
        return classM
    }
    
    func convertDicToCourse(_ dic: [String: AnyJSON]) -> CourseModel {
        let id = dic["id"]?.intValue
        let name = dic["name"]?.stringValue ?? ""
        let id_school = dic["id_school"]?.intValue

        let course = CourseModel(id: id, id_school: id_school, name: name)
        
        return course
    }
}
