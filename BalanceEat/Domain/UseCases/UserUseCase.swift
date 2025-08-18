//
//  UserUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation

protocol UserUseCaseProtocol {
    func createUser(createUserDTO: CreateUserDTO) async -> Result<Void, NetworkError>
}

struct UserUseCase: UserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func createUser(createUserDTO: CreateUserDTO) async -> Result<Void, NetworkError> {
        await repository.createUser(createUserDTO: createUserDTO)
    }
}
