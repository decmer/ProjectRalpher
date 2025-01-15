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
    
    func fetchSchools() async throws {
        schools = try await supabase.database.from("schools").select("*").execute().value
        self.handleDatabaseChange(self.schools)
    }
    
    func fetchSchoolsKey() async throws -> String {
        let str: String = try await supabase.database.from("schools_key").select("codejoin").limit(1).execute().value
        return str
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
    
    func subscribeToUserUpdates() async {
//        channelUser = await supabase.realtimeV2.channel("users")
//
//        guard let channel = channelUser else { return }
//
//        let insertStream = await channel.postgresChange(InsertAction.self, schema: "public", table: "users")
//
//        // Crear un flujo para escuchar actualizaciones
//        let updateStream = await channel.postgresChange(UpdateAction.self, schema: "public", table: "users")
//
//        // Crear un flujo para escuchar eliminaciones
//        let deleteStream = await channel.postgresChange(DeleteAction.self, schema: "public", table: "users")
//
//        // Escuchar cambios en el flujo de inserciones
//        Task {
//        for await insertAction in insertStream {
//        DispatchQueue.main.async {
//        print("Inserted: \(insertAction.record)")
//        }
//        }
//        }
//
//        // Escuchar cambios en el flujo de actualizaciones
//        Task {
//            for await updateAction in updateStream {
//                DispatchQueue.main.async {
//                    print("Updated: \(updateAction.oldRecord) with \(updateAction.record)")
//                }
//            }
//        }
//
//        // Escuchar cambios en el flujo de eliminaciones
//        Task {
//            for await deleteAction in deleteStream {
//                DispatchQueue.main.async {
//                    print("Deleted: \(deleteAction.oldRecord)")
//                }
//            }
//        }
//
//        // Intentar suscribirse al canal
//        await channel.subscribe()
//        print("Subscribed to 'users' channel.")
    }
    
    func subscribeToSchoolsUpdates() async {
        channelSchools = await supabase.realtimeV2.channel("schools")
                
        guard let channel = channelSchools else { return }
        
        let insertStream = await channel.postgresChange(InsertAction.self, schema: "public", table: "schools")
            
        let updateStream = await channel.postgresChange(UpdateAction.self, schema: "public", table: "schools")
            
        let deleteStream = await channel.postgresChange(DeleteAction.self, schema: "public", table: "schools")

            Task {
                for await insertAction in insertStream {
                    DispatchQueue.main.async {
                        self.schools?.append(self.convertDicToSchools(insertAction.record))
                        self.handleDatabaseChange(self.schools)
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
                        self.handleDatabaseChange(self.schools)
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
                        self.handleDatabaseChange(self.schools)
                    }
                }
            }

            await channel.subscribe()
        }
}

extension ViewModel {
    func convertDicToSchools(_ dic: [String: AnyJSON]) -> SchoolsModel {
        let id = dic["id"]?.intValue
        let name = dic["name"]?.stringValue ?? ""
        let color = dic["color"]?.stringValue
        let image = dic["image"]?.stringValue

        let school = SchoolsModel(id: id, name: name, color: color, image: image)
        
        return school
    }
    
    func handleDatabaseChange(_ payload: [SchoolsModel]?) {
        // Guarda los datos en App Groups para que el widget pueda acceder
//        if let sharedDefaults = UserDefaults(suiteName: "group.com.decmer.ralpher") {
//            sharedDefaults.set(payload, forKey: "ultimoCambio")
//        }
        
        // Notifica al widget que debe actualizarse
        WidgetCenter.shared.reloadAllTimelines()
    }
}
