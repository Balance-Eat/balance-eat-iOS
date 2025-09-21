//
//  DietUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//

import Foundation

protocol DietUseCaseProtocol {
    func getDailyDiet(date: Date, userId: String) async -> Result<[DietDTO], NetworkError>
}

struct DietUseCase: DietUseCaseProtocol {
    private let repository: DietRepositoryProtocol
    
    init(repository: DietRepositoryProtocol) {
        self.repository = repository
    }
    
    func getDailyDiet(date: Date, userId: String) async -> Result<[DietDTO], NetworkError> {
        await repository.getDailyDiet(date: date, userId: userId)
    }
}
