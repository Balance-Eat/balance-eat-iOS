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
    
    func createUser(_ request: UserCreateRequest) async -> Result<Void, NetworkError> {
        let userDTO = UserDTO(
            uuid: request.uuid,
            name: request.name,
            gender: request.gender,
            age: request.age,
            height: request.height,
            weight: request.weight,
            goalType: request.goalType,
            email: request.email,
            activityLevel: request.activityLevel,
            smi: request.smi,
            fatPercentage: request.fatPercentage,
            targetWeight: request.targetWeight,
            targetCalorie: request.targetCalorie,
            targetSmi: request.targetSmi,
            targetFatPercentage: request.targetFatPercentage,
            targetCarbohydrates: request.targetCarbohydrates,
            targetProtein: request.targetProtein,
            targetFat: request.targetFat,
            providerId: request.providerId,
            providerType: request.providerType
        )
        let endpoint = UserEndPoints.createUser(userDTO: userDTO)
        let result = await apiClient.request(endpoint: endpoint, responseType: EmptyResponse.self)
        switch result {
        case .success: return .success(())
        case .failure(let error): return .failure(error)
        }
    }

    func updateUser(_ userData: UserData) async -> Result<Void, NetworkError> {
        let userDTO = UserDTO(
            id: userData.id,
            uuid: userData.uuid,
            name: userData.name,
            gender: userData.gender,
            age: userData.age,
            height: userData.height,
            weight: userData.weight,
            goalType: userData.goalType,
            email: userData.email,
            activityLevel: userData.activityLevel,
            smi: userData.smi,
            fatPercentage: userData.fatPercentage,
            targetWeight: userData.targetWeight,
            targetCalorie: userData.targetCalorie,
            targetSmi: userData.targetSmi,
            targetFatPercentage: userData.targetFatPercentage,
            targetCarbohydrates: userData.targetCarbohydrates,
            targetProtein: userData.targetProtein,
            targetFat: userData.targetFat,
            providerId: userData.providerId,
            providerType: userData.providerType
        )
        let endpoint = UserEndPoints.updateUser(userDTO: userDTO)
        let result = await apiClient.request(endpoint: endpoint, responseType: EmptyResponse.self)
        switch result {
        case .success: return .success(())
        case .failure(let error): return .failure(error)
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

