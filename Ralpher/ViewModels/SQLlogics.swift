//
//  SQLlogics.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 18/12/24.
//

import Foundation
import Supabase
import Realtime
import WidgetKit

extension ViewModel {
    
    func fetchUser(id: UUID) async throws -> UserModel? {
        let str: [UserModel] = try await supabase.database.from("users").select("*").eq("id", value: id).execute().value
        return str.first
    }
    
    func fetchSchools() async throws {
        schools = try await supabase.database.from("schools").select("*").execute().value
    }
    
    func fetchUseersToSchools(_ idSchool: Int) async throws {
        let result: [[String: AnyJSON]] = try await supabase.database.from("users_schools").select("user_id, role").eq("school_id", value: idSchool).execute().value
        var userToSchoolAux = [(UserModel, RoleSchool)]()
        for item in result {
            let id = item["user_id"]?.stringValue ?? ""
            let role = item["role"]?.stringValue ?? ""
            await userToSchoolAux.append((try fetchUser(id: UUID(uuidString: id)!)!, RoleSchool(rawValue: role)!))
        }
        self.userToSchool = userToSchoolAux
    }
    
    func fetchSchoolsKey() async throws -> String {
        if let school = self.schoolSelected {
            let str: [[String: AnyJSON]] = try await supabase.database.from("schools_key").select("codejoin").eq("id", value: school.id!).execute().value
            return str.first?["codejoin"]?.stringValue ?? "error"
        } else {
            return "error"
        }
    }
    
    func fetchClass() async throws {
        if let schools = self.schoolSelected {
            let classMAux: [ClassModel] = try await supabase.database.from("class").select("*").execute().value
            self.classM = classMAux.filter({ $0.id_school == schools.id })
        }
    }
    
    func addUserToSchool(_ codejoin: String) async throws{
        let parameters: [String: String] = ["codejoininput": codejoin]
        try await supabase.database.rpc("join_user_to_school", params: parameters).execute().value
    }
    
    func createSchool(_ school: SchoolsModel) async throws {
        try await supabase.database
            .from("schools")
            .insert(school)
            .execute()
    }
    
    func deleteSchool(_ school: SchoolsModel) async throws {
        try await supabase.database
            .from("schools")
            .delete()
            .eq("id", value: school.id!)
            .execute()
    }
    
    func dropOutOfSchool(_ school: SchoolsModel) async throws {
        try await supabase.database
            .from("users_schools")
            .delete()
            .eq("school_id", value: school.id!)
            .execute()
    }
    
    func createClass(_ classM: ClassModel) async throws {
        try await supabase.database
            .from("class")
            .insert(classM)
            .execute()
    }
    
    func createUser(_ firstName: String, lastName: String) async throws {
        try await supabase.database.rpc("create_user", params: ["first_name": firstName, "last_name": lastName]).execute().value
    }
    
    func isExistUsersPublicTable() async throws {

        let userId = try await supabase.auth.user().id
        // Realizar la consulta para verificar si el usuario está en la tabla public.users
        let data: UserModel? = try await supabase.database.from("users").select().eq("id", value: userId).single().execute().value

        if let user = data {
            print("El usuario está en la tabla: \(user)")
            // Aquí puedes manejar la lógica si el usuario existe
        } else {
            print("El usuario no se encontró en la tabla.")
            // Aquí puedes manejar la lógica si el usuario no existe
        }
    }
    
    func updateSchool() async throws {
        if let school = self.schoolSelected {
            let updatedValues: [String: AnyJSON] = [
                "name": .string(school.name),
                "color": .string(school.color ?? "color")
            ]
            
            // Realiza la actualización en la tabla 'schools'
            try await supabase.database
                .from("schools")
                .update(updatedValues)
                .eq("id", value: school.id!)
                .execute()
            
            print("Registro de escuela actualizado con éxito.")
        } else {
            print("Error al actualizar el registro de escuela. No se encontró el ID del registro.")
        }
    }
    
    func updateUser() async throws {
        if let user = self.users {
            
            let userId = try await supabase.auth.user().id
            
            try await supabase.database
                .from("users")
                .update([
                    "name": user.name,
                    "surname": user.surname,
                    "imgname": user.imgname,
                    "imgurl": user.imgurl
                ])
                .eq("id", value: userId)
                .execute()
        }
    }
    
    func uploadImage(_ data: Data, name: String) async throws {
        let fileName = UUID().uuidString
        
        try await supabase.storage.from("img")
            .upload(
                path: fileName,
                file: data,
                options: FileOptions(contentType: "image/jpeg")
            )
        if let oldFileName = self.users?.imgname {
            try await removeItemBucket([oldFileName], bucketName: "img")
        }
        self.users?.imgname = fileName
        self.users?.imgurl = try await getURLBucket(fileName).absoluteString
        try await updateUser()
    }
    
    func getURLBucket(_ fileName: String) async throws -> URL {
        let bucket = supabase.storage.from("img")
        return try bucket.getPublicURL(path: fileName)
    }
    
    func removeItemBucket(_ fileName: [String], bucketName: String) async throws {
        let bucket = supabase.storage.from(bucketName)
        try await bucket.remove(paths: fileName)
    }
    
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
