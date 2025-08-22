//
//  DietUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//

import Foundation

protocol DietUseCaseProtocol {
    func getDailyDiet(date: Date) async -> Result<DailyDietResponseDTO, NetworkError>
}

struct DietUseCase: DietUseCaseProtocol {
    private let repository: DietRepositoryProtocol
    
    init(repository: DietRepositoryProtocol) {
        self.repository = repository
    }
    
    func getDailyDiet(date: Date) async -> Result<DailyDietResponseDTO, NetworkError> {
        await repository.getDailyDiet(date: date)
    }
}
