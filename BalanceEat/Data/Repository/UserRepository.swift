//
//  UserRepository.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation
import CoreData
import UIKit

struct UserRepository: UserRepositoryProtocol {
    private let apiClient = APIClient.shared
    private var context: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate를 가져올 수 없습니다!")
        }
        return appDelegate.persistentContainer.viewContext
    }


    
    private var userCoreData: UserCoreData {
        UserCoreData(viewContext: context)
    }
    
    func createUser(userDTO: UserDTO) async -> Result<Void, NetworkError> {
        let endpoint = UserEndPoints.createUser(userDTO: userDTO)
        let result = await apiClient.request(
            endpoint: endpoint,
            responseType: EmptyResponse.self
        )
                
        switch result {
        case .success:
            print("user created success")
            return .success(())
        case .failure(let error):
            print("user created failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    func updateUser(userDTO: UserDTO) async -> Result<Void, NetworkError> {
        let endpoint = UserEndPoints.updateUser(userDTO: userDTO)
        let result = await apiClient.request(
            endpoint: endpoint,
            responseType: EmptyResponse.self
        )
        
        switch result {
        case .success:
            print("user updated success")
            return .success(())
        case .failure(let error):
            print("user updated failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    func getUser(uuid: String) async -> Result<UserResponseDTO, NetworkError> {
        let endpoint = UserEndPoints.getUser(uuid: uuid)
        let result = await apiClient.request(
            endpoint: endpoint,
            responseType: BaseResponse<UserResponseDTO>.self
        )
        
        switch result {
        case .success(let response):
            print("get user success \(response)")
            return .success(response.data)
        case .failure(let error):
            print("get user failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    func getUserUUID() -> Result<String, CoreDataError> {
        userCoreData.getUserUUID()
    }
    
    func saveUserUUID(_ uuid: String) -> Result<Void, CoreDataError> {
        userCoreData.saveUserUUID(uuid)
    }
    
    func deleteUserUUID(_ uuid: String) -> Result<Void, CoreDataError> {
        userCoreData.deleteUserUUID(uuid)
    }
    
    func getUserId() -> Result<Int64, CoreDataError> {
        userCoreData.getUserId()
    }
    func saveUserId(_ userId: Int64) -> Result<Void, CoreDataError> {
        userCoreData.saveUserId(userId)
    }
    func deleteUserId(_ userId: Int64) -> Result<Void, CoreDataError> {
        userCoreData.deleteUserId(userId)
    }
    
}

