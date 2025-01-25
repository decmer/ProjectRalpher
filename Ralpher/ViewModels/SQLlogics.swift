//
//  SQLlogics.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 18/12/24.
//

import Foundation
import Supabase
import Realtime
import SwiftUI

extension ViewModel {
    
    /// funcion para obtener el modelo de un usuario en particular
    func fetchUser(id: UUID) async throws -> UserModel? {
        let str: [UserModel] = try await supabase.database.from("users").select("*").eq("id", value: id).execute().value
        return str.first
    }
    
    /// funcion para podder ver todas las escuelas, por reglas de filas en el servidor solo podra ver las pertenecientes a susu usario
    func fetchSchools() async throws {
        let schools: [SchoolsModel]? = try await supabase.database.from("schools").select("*").execute().value
        withAnimation {
            self.schools = schools
        }
    }
    
    /// funcion para ver todos los usuarios pertenecientes a esta escuela
    func fetchUseersToSchools(_ idSchool: Int) async throws -> [(UserModel, RoleSchool)] {
        let result: [[String: AnyJSON]] = try await supabase.database.from("users_schools").select("user_id, role").eq("school_id", value: idSchool).execute().value
        var userToSchoolAux = [(UserModel, RoleSchool)]()
        for item in result {
            let id = item["user_id"]?.stringValue ?? ""
            let role = item["role"]?.stringValue ?? ""
            await userToSchoolAux.append((try fetchUser(id: UUID(uuidString: id)!)!, RoleSchool(rawValue: role)!))
        }
        return userToSchoolAux
    }
    
    /// funcion para saber el rol del usuario en la escuela
    func fetchRoleToSchools(_ idSchool: Int) async throws -> RoleSchool? {
        let result: [[String: AnyJSON]] = try await supabase.database.from("users_schools").select("role").eq("school_id", value: idSchool).eq("user_id", value: users!.id).execute().value
        if let item = result.first {
            let role = item["role"]?.stringValue ?? ""
            return RoleSchool(rawValue: role)
        }
        return nil
    }
    
    /// funcion para ver la clave publica de la escuela, para poder unirte a ella
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
    
    func fetchClass(_ id: Int) async throws -> ClassModel? {
        if let schools = self.schoolSelected {
            let classMAux: ClassModel? = try await supabase.database.from("class").select("*").eq("id", value: id).limit(1).execute().value
            if let classM = classMAux {
                return classM
            }
        }
        return nil
    }
    
    func fetchCourse() async throws -> [CourseModel]? {
        if let school = self.schoolSelected {
            let courseModel: [CourseModel] = try await supabase.database.from("course").select("*").eq("id_school", value: school.id!).execute().value
            return courseModel
        }
        return nil
    }
    
    func prepareCacheCourseUsersSchool(_ idCourse: Int) async throws -> ([UserModel], [ClassModel])? {
        if let courseUsersSchool = try await fetchCourseUsersSchool(idCourse), let courseCLass = try await fetchCourseClass(idCourse) {
            return (courseUsersSchool, courseCLass)
        }
        return nil
    }
    
    func fetchCourseUsersSchool(_ idCourse: Int) async throws -> [UserModel]? {
        if let school = self.schoolSelected {
            let result: [[String: AnyJSON]] = try await supabase.database.from("course_users_school").select("id_user").eq("id_school", value: school.id!).eq("id_course", value: idCourse).execute().value
            var courseUsersSchool = [UserModel]()
            for item in result {
                let id = item["id_user"]?.stringValue ?? ""
                await courseUsersSchool.append(try fetchUser(id: UUID(uuidString: id)!)!)
            }
            return courseUsersSchool
        }
        return nil
    }
    
    func fetchCourseClass(_ idCourse: Int) async throws -> [ClassModel]? {
        if let school = self.schoolSelected {
            let result: [[String: AnyJSON]] = try await supabase.database.from("course_class").select("id_class").eq("id_course", value: idCourse).execute().value
            var courseClass = [ClassModel]()
            for item in result {
                let id = item["id_class"]?.intValue
                await courseClass.append(try fetchClass(id!)!)
            }
            return courseClass
        }
        return nil
    }
    
    //Sentencias Insert
    
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
        if let id = users?.id {
            try await supabase.database
                .from("users_schools")
                .delete()
                .eq("school_id", value: school.id!)
                .eq("user_id", value: id)
                .execute()
        }
    }
    
    func deleteUserSchool(_ user: UserModel) async throws {
        if let id = schoolSelected?.id {
            try await supabase.database
                .from("users_schools")
                .delete()
                .eq("school_id", value: id)
                .eq("user_id", value: user.id)
                .execute()
        }
    }
    
    func createClass(_ classM: ClassModel) async throws {
        try await supabase.database
            .from("class")
            .insert(classM)
            .execute()
    }
    
    func createCourse(_ name: String) async throws {
        if let id = schoolSelected?.id {
            let course = CourseModel(id_school: id, name: name)
            try await supabase.database
                .from("course")
                .insert(course)
                .execute()
        }
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
            try await removeItemBucket(oldFileName, bucketName: "img")
        }
        self.users?.imgname = fileName
        self.users?.imgurl = try await getURLBucket(fileName).absoluteString
        try await updateUser()
    }
    
    func getURLBucket(_ fileName: String) async throws -> URL {
        let bucket = supabase.storage.from("img")
        return try bucket.getPublicURL(path: fileName)
    }
    
    func removeItemBucket(_ fileName: String, bucketName: String) async throws {
        if fileName != "userProfileBasic.png" {
            let bucket = supabase.storage.from(bucketName)
            try await bucket.remove(paths: [fileName])
        }
    }
    
    

    func updateUserRole(userId: UUID, newRole: String) async throws {
        let updatedValues: [String: AnyJSON] = [
            "role": .string(newRole)
        ]
        if let idSchool = self.schoolSelected?.id {
            try await supabase.database
                .from("users_schools")
                .update(updatedValues)
                .eq("user_id", value: userId)
                .eq("school_id", value: idSchool)
                .execute()
        }
    }
}
