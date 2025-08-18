//
//  UserRepository.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation

protocol UserRepositoryProtocol {
    func createUser(createUserDTO: CreateUserDTO) async -> Result<Void, NetworkError>
    
}
