//
//  UserUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation

protocol UserUseCaseProtocol {
    func createUser(createUserDTO: CreateUserDTO) async -> Result<Void, NetworkError>
    func getUser(uuid: String) async -> Result<UserResponseDTO, NetworkError>
    func getUserUUID() -> Result<String, CoreDataError>
    func saveUserUUID(_ uuid: String) -> Result<Void, CoreDataError>
    func deleteUserUUID(_ uuid: String) -> Result<Void, CoreDataError>
}

struct UserUseCase: UserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func createUser(createUserDTO: CreateUserDTO) async -> Result<Void, NetworkError> {
        await repository.createUser(createUserDTO: createUserDTO)
    }
    
    func getUser(uuid: String) async -> Result<UserResponseDTO, NetworkError> {
        await repository.getUser(uuid: uuid)
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
