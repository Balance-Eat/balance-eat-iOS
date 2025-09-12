//
//  UserUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation

protocol UserUseCaseProtocol {
    func createUser(userDTO: UserDTO) async -> Result<Void, NetworkError>
    func updateUser(userDTO: UserDTO) async -> Result<Void, NetworkError> 
    func getUser(uuid: String) async -> Result<UserData, NetworkError>
    func getUserUUID() -> Result<String, CoreDataError>
    func saveUserUUID(_ uuid: String) -> Result<Void, CoreDataError>
    func deleteUserUUID(_ uuid: String) -> Result<Void, CoreDataError>
}

struct UserUseCase: UserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func createUser(userDTO: UserDTO) async -> Result<Void, NetworkError> {
        await repository.createUser(userDTO: userDTO)
    }
    
    func updateUser(userDTO: UserDTO) async -> Result<Void, NetworkError> {
        await repository.updateUser(userDTO: userDTO)
    }
    
    func getUser(uuid: String) async -> Result<UserData, NetworkError> {
        let response = await repository.getUser(uuid: uuid)
        
        switch response {
        case .success(let userResponseDTO):
            return .success(UserData.responseDTOToModel(userResponseDTO: userResponseDTO))
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func getUserUUID() -> Result<String, CoreDataError> {
        repository.getUserUUID()
    }
    
    func saveUserUUID(_ uuid: String) -> Result<Void, CoreDataError> {
        repository.saveUserUUID(uuid)
    }
    
    func deleteUserUUID(_ uuid: String) -> Result<Void, CoreDataError> {
        repository.deleteUserUUID(uuid)
    }
}
