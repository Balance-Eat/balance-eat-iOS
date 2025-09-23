//
//  DietUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//

import Foundation

protocol DietUseCaseProtocol {
    func createDiet(mealTime: MealTime, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String) async -> Result<CreateDietResponseDTO, NetworkError>
    func getDailyDiet(date: Date, userId: String) async -> Result<[DietDTO], NetworkError>
}

struct DietUseCase: DietUseCaseProtocol {
    private let repository: DietRepositoryProtocol
    
    init(repository: DietRepositoryProtocol) {
        self.repository = repository
    }
    
    func createDiet(mealTime: MealTime, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String) async -> Result<CreateDietResponseDTO, NetworkError> {
        await repository.createDiet(mealTime: mealTime, consumedAt: consumedAt, dietFoods: dietFoods, userId: userId)
    }
    
    func getDailyDiet(date: Date, userId: String) async -> Result<[DietDTO], NetworkError> {
        await repository.getDailyDiet(date: date, userId: userId)
    }
}
