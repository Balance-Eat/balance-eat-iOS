//
//  UserRepository.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation

struct UserRepository: UserRepositoryProtocol {
    func createUser(createUserDTO: CreateUserDTO) async -> Result<Void, NetworkError> {
        let endpoint = UserEndPoints.createUser(createUserDTO: createUserDTO)
        let result: Result<EmptyResponse, NetworkError> = await APIClient.shared.request(
            endpoint: endpoint,
            responseType: EmptyResponse.self
        )
                
        switch result {
        case .success:
            print("user created success")
            return .success(())
        case .failure(let error):
            print("user created failed: \(error)")
            return .failure(error)
        }
    }
}

