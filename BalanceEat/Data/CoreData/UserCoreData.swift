//
//  UserCoreData.swift
//  BalanceEat
//
//  Created by 김견 on 8/20/25.
//

import Foundation
import CoreData


protocol UserCoreDataProtocol {
    func getUserUUID() -> Result<String, CoreDataError>
    func saveUserUUID(_ uuid: String) -> Result<Void, CoreDataError>
    func deleteUserUUID(_ uuid: String) -> Result<Void, CoreDataError>
}

struct UserCoreData: UserCoreDataProtocol {
    private let viewContext: NSManagedObjectContext
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func getUserUUID() -> Result<String, CoreDataError> {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let result = try viewContext.fetch(fetchRequest)
            print("getUserUUID result: \(result)")
            guard let uuid = result.first?.uuid else {
                return .failure(.readError("uuid not found"))
            }
            return .success(uuid)
        } catch {
            return .failure(.readError(error.localizedDescription))
        }
    }
    
    func saveUserUUID(_ uuid: String) -> Result<Void, CoreDataError> {
        guard let entity = NSEntityDescription.entity(forEntityName: "User", in: viewContext) else {
            return .failure(.entityNotFound("User"))
        }
        let userObject = NSManagedObject(entity: entity, insertInto: viewContext)
        userObject.setValue(uuid, forKey: "uuid")
        
        do {
            try viewContext.save()
            return .success(())
        } catch {
            return .failure(.saveError(error.localizedDescription))
        }
    }
    
    func deleteUserUUID(_ uuid: String) -> Result<Void, CoreDataError> {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid)
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            result.forEach { user in
                viewContext.delete(user)
            }
            try viewContext.save()
            return .success(())
        } catch {
            return .failure(.deleteError(error.localizedDescription))
        }
    }
}
