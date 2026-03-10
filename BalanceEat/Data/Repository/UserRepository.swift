//
//  UserRepository.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation
import CoreData

struct UserRepository: UserRepositoryProtocol {
    private let apiClient = APIClient.shared
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
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
            return .success(())
        case .failure(let error):
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
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getUser(uuid: String) async -> Result<UserData, NetworkError> {
        let endpoint = UserEndPoints.getUser(uuid: uuid)
        let result = await apiClient.request(
            endpoint: endpoint,
            responseType: BaseResponse<UserResponseDTO>.self
        )
        
        switch result {
        case .success(let response):
            return .success(response.data.toDomain())
        case .failure(let error):
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

