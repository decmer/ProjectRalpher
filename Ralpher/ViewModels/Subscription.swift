//
//  Subscription.swift
//  Ralpher
//
//  Created by Jose Decena on 23/1/25.
//

import Foundation
import Realtime
import Supabase

extension ViewModel {
    
    func subscribeToUserUpdates() async {
        channelSchools = await supabase.realtimeV2.channel("users")
                
        guard let channel = channelSchools else { return }
        
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
                            await self.logoutUser()
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
                DispatchQueue.main.async {
                    let updatedSchool = self.convertDicToSchools(updateAction.record)
                    let oldSchool = self.convertDicToSchools(updateAction.oldRecord)
                    if let index = self.schools?.firstIndex(where: { $0.id == oldSchool.id }) {
                        self.schools?[index] = updatedSchool
                    }
                }
                
            }
        }
    
        Task {
            for await deleteAction in deleteStream {
                DispatchQueue.main.async {
                    let idSchool = self.convertDicToSchools(deleteAction.oldRecord).id
                    self.schools?.removeAll(where: { SchoolsModel in
                        idSchool == SchoolsModel.id
                    })
                }
            }
        }

        await channel.subscribe()
    }
    
    func subscribeToUsersSchools() async {
        channelSchools = await supabase.realtimeV2.channel("schools")
                
        guard let channel = channelSchools else { return }
        
        let insertStream = await channel.postgresChange(InsertAction.self, schema: "public", table: "schools")
            
        let updateStream = await channel.postgresChange(UpdateAction.self, schema: "public", table: "schools")
            
        let deleteStream = await channel.postgresChange(DeleteAction.self, schema: "public", table: "schools")

        Task {
            for await insertAction in insertStream {
                if let usersToSchool = self.userToSchool {
                    let newUserSchool = try await self.convertDicToUsersSchools(insertAction.record)
                    if let newUserSchool = newUserSchool, newUserSchool.2 == self.schoolSelected?.id {
                        self.userToSchool?.append((newUserSchool.0, newUserSchool.1))
                    }
                }
            }
        }
    
        Task {
            for await updateAction in updateStream {
                DispatchQueue.main.async {
                    
                }
                
            }
        }
    
        Task {
            for await deleteAction in deleteStream {
                DispatchQueue.main.async {
                    
                }
            }
        }

        await channel.subscribe()
    }
    
    func subscribeToClass() async {
        channelSchools = await supabase.realtimeV2.channel("class")
                
        guard let channel = channelSchools else { return }
        
        let insertStream = await channel.postgresChange(InsertAction.self, schema: "public", table: "class")
            
        let updateStream = await channel.postgresChange(UpdateAction.self, schema: "public", table: "class")
            
        let deleteStream = await channel.postgresChange(DeleteAction.self, schema: "public", table: "class")

            Task {
                for await insertAction in insertStream {
                    DispatchQueue.main.async {
                        if let schoolSelected = self.schoolSelected {
                            let classM = self.convertDicToClass(insertAction.record)
                            if classM.id_school == schoolSelected.id {
                                self.classM?.append(classM)
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
                                    self.classM?[index] = updatedClass
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
                                self.classM?.removeAll(where: { ClassModel in
                                    idClass == ClassModel.id
                                })
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
        let image = dic["image"]?.stringValue

        let school = SchoolsModel(id: id, name: name, color: color, image: image)
        
        return school
    }
    
    func convertDicToUsersSchools(_ dic: [String: AnyJSON]) async throws -> (UserModel, RoleSchool, Int)? {
        let userID = UUID(uuidString: dic["user_id"]?.stringValue ?? "")!
        let role = dic["role"]?.stringValue ?? ""
        let schoolID = dic["school_id"]?.intValue ?? 0

        let user = try await fetchUser(id: userID)
        let schoolRole = RoleSchool(rawValue: role)
        if let user = user, let schoolRole = schoolRole {
            return (user, schoolRole, schoolID)
        }
        return nil
    }
    
    func convertDicToClass(_ dic: [String: AnyJSON]) -> ClassModel {
        let id = dic["id"]?.intValue
        let id_school = dic["id_school"]?.intValue
        let name = dic["name"]?.stringValue ?? ""
        let description = dic["description"]?.stringValue
        let color = dic["color"]?.stringValue

        let classM = ClassModel(id: id, name: name, description: description, id_school: id_school, color: color)
        
        return classM
    }
}
