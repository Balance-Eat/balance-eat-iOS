//
//  UserUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation

protocol UserUseCaseProtocol {
    func createUser(request: UserCreateRequest) async -> Result<Void, NetworkError>
    func updateUser(userData: UserData) async -> Result<Void, NetworkError>
    func getUser(uuid: String) async -> Result<UserData, NetworkError>
    func getUserUUID() -> Result<String, CoreDataError>
    func saveUserUUID(_ uuid: String) -> Result<Void, CoreDataError>
    func deleteUserUUID(_ uuid: String) -> Result<Void, CoreDataError>
    func getUserId() -> Result<Int64, CoreDataError>
    func saveUserId(_ userId: Int64) -> Result<Void, CoreDataError>
    func deleteUserId(_ userId: Int64) -> Result<Void, CoreDataError>
}

struct UserUseCase: UserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func createUser(request: UserCreateRequest) async -> Result<Void, NetworkError> {
        await repository.createUser(request: request)
    }

    func updateUser(userData: UserData) async -> Result<Void, NetworkError> {
        await repository.updateUser(userData: userData)
    }
    
    func getUser(uuid: String) async -> Result<UserData, NetworkError> {
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
    
    func getUserId() -> Result<Int64, CoreDataError> {
        repository.getUserId()
    }
    func saveUserId(_ userId: Int64) -> Result<Void, CoreDataError> {
        repository.saveUserId(userId)
    }
    func deleteUserId(_ userId: Int64) -> Result<Void, CoreDataError> {
        repository.deleteUserId(userId)
    }
}
